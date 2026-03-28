import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../models/live_user_model.dart';
import '../models/profile_model.dart';
import '../services/prefs_helper.dart';
import '../services/auth_service.dart';

class LiveProvider with ChangeNotifier {
  static const String _liveCollection = 'live_users';
  static const String _usersCollection = 'users';

  final List<LiveUserModel> _activeUsers = <LiveUserModel>[];
  final List<LiveUserModel> _allUsers = <LiveUserModel>[];

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _activeSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _allUsersSubscription;
  StreamSubscription<User?>? _authSubscription;
  Timer? _heartbeatTimer;

  String? _myUserId;
  double? _myLatitude;
  double? _myLongitude;

  List<LiveUserModel> get activeUsers => List<LiveUserModel>.unmodifiable(_activeUsers);
  List<LiveUserModel> get allUsers => List<LiveUserModel>.unmodifiable(_allUsers);

  double? get myLatitude => _myLatitude;
  double? get myLongitude => _myLongitude;

  bool get isListening => _activeSubscription != null;

  void startRealtime() {
    // Check if Firebase is initialized
    if (Firebase.apps.isEmpty) {
      debugPrint('Firebase not initialized, deferring startRealtime');
      return;
    }

    // Initialize listeners if user exists (either Firebase auth or local account)
    _initUserStateListener();
  }

  Future<void> _initUserStateListener() async {
    // Check for local user first
    final localUserId = await PrefsHelper.getUserId();
    
    // Set up dual listener: Firebase auth changes AND local user state
    _authSubscription?.cancel();
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((_) {
      _checkAndInitializeListeners();
    });
    
    // Also check immediately in case user is local (not Firebase authenticated)
    _checkAndInitializeListeners();
  }

  Future<void> _checkAndInitializeListeners() async {
    final localUserId = await PrefsHelper.getUserId();
    final firebaseUser = FirebaseAuth.instance.currentUser;
    
    // Initialize if user has either Firebase auth OR local user ID
    if (firebaseUser != null || (localUserId != null && localUserId.isNotEmpty)) {
      debugPrint('User ready (Firebase: ${firebaseUser?.uid}, Local: $localUserId), initializing Firestore listeners');
       // Ensure anonymous auth for local users
       if (firebaseUser == null && localUserId != null) {
         final anonSuccess = await AuthService.signInAnonymously();
         if (!anonSuccess) {
           debugPrint('Failed to authenticate anonymously, listeners may not work');
         }
       }
       _initializeFirestoreListeners();
    } else {
      debugPrint('No user found, cancelling Firestore listeners');
      _cancelListeners();
    }
  }

  void _initializeFirestoreListeners() {
    _updateAccountLocationSnapshot();

    _activeSubscription ??= FirebaseFirestore.instance
        .collection(_liveCollection)
        .where('isLive', isEqualTo: true)
        .snapshots()
        .listen(
      (snapshot) {
        final users = snapshot.docs
            .map((doc) {
              final data = doc.data();
              data['userId'] = (data['userId'] as String?)?.isNotEmpty == true
                  ? data['userId']
                  : doc.id;
              return LiveUserModel.fromMap(data);
            })
            .where((u) => !u.isStale && u.latitude != 0 && u.longitude != 0)
            .toList();

        users.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

        _activeUsers
          ..clear()
          ..addAll(users);
        notifyListeners();
      },
      onError: (error) {
        debugPrint('Live users listener error: $error');
      },
    );

    _allUsersSubscription ??= FirebaseFirestore.instance
        .collection(_usersCollection)
        .snapshots()
        .listen(
      (snapshot) {
        final users = snapshot.docs
            .map((doc) {
              final data = doc.data();
              data['userId'] = (data['userId'] as String?)?.isNotEmpty == true
                  ? data['userId']
                  : doc.id;
              return LiveUserModel.fromMap(data);
            })
            .where((u) => u.latitude != 0 && u.longitude != 0)
            .toList();

        users.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        _allUsers
          ..clear()
          ..addAll(users);
        notifyListeners();
      },
      onError: (error) {
        debugPrint('All users map listener error: $error');
      },
    );
  }


  void _cancelListeners() {
    _activeSubscription?.cancel();
    _activeSubscription = null;
    _allUsersSubscription?.cancel();
    _allUsersSubscription = null;
    _activeUsers.clear();
    _allUsers.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _heartbeatTimer?.cancel();
    _activeSubscription?.cancel();
    _allUsersSubscription?.cancel();
    super.dispose();
  }

  Future<void> _updateAccountLocationSnapshot() async {
    final userId = await PrefsHelper.getUserId();
    if (userId == null || userId.isEmpty) {
      return;
    }

    final position = await _ensureAndGetPosition();
    if (position == null) {
      return;
    }

    _myUserId = userId;
    _myLatitude = position.latitude;
    _myLongitude = position.longitude;

    await FirebaseFirestore.instance.collection(_usersCollection).doc(userId).set(
      {
        'userId': userId,
        'latitude': _myLatitude,
        'longitude': _myLongitude,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      },
      SetOptions(merge: true),
    );
    notifyListeners();
  }

  Future<Position?> _ensureAndGetPosition({
    bool openSettingsOnFailure = false,
  }) async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (openSettingsOnFailure) {
        await Geolocator.openLocationSettings();
      }
      return null;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      return null;
    }

    if (permission == LocationPermission.deniedForever) {
      if (openSettingsOnFailure) {
        await Geolocator.openAppSettings();
      }
      return null;
    }

    return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  double _distanceKmBetween({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) {
    final meters = Geolocator.distanceBetween(fromLat, fromLng, toLat, toLng);
    return (meters / 1000.0);
  }

  Future<bool> goLive({
    required ProfileModel? profile,
    required String intent,
    List<String> tags = const <String>[],
  }) async {
    if (Firebase.apps.isEmpty) {
      return false;
    }

    final userId = profile?.userId ?? await PrefsHelper.getUserId();
    if (userId == null || userId.isEmpty) {
      return false;
    }

    _myUserId = userId;
    final position = await _ensureAndGetPosition(openSettingsOnFailure: true);
    if (position == null) {
      return false;
    }
    _myLatitude = position.latitude;
    _myLongitude = position.longitude;

    final currentLat = _myLatitude!;
    final currentLng = _myLongitude!;

    final payload = LiveUserModel(
      userId: userId,
      name: (profile?.fullName.isNotEmpty ?? false)
          ? profile!.fullName
          : 'You',
      age: profile?.age ?? 0,
      intent: intent,
      tags: tags,
      latitude: currentLat,
      longitude: currentLng,
      distanceKm: 0,
      isLive: true,
      updatedAt: DateTime.now(),
    );

    await FirebaseFirestore.instance
        .collection(_liveCollection)
        .doc(userId)
        .set(payload.toMap(), SetOptions(merge: true));

    await FirebaseFirestore.instance.collection(_usersCollection).doc(userId).set(
      payload.toMap(),
      SetOptions(merge: true),
    );

    startRealtime();
    _startHeartbeat(intent: intent, profile: profile, tags: tags);
    notifyListeners();
    return true;
  }

  Future<void> stopLive() async {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;

    if (Firebase.apps.isEmpty || _myUserId == null) {
      return;
    }

    await FirebaseFirestore.instance
      .collection(_liveCollection)
        .doc(_myUserId)
        .set(
      {
        'isLive': false,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      },
      SetOptions(merge: true),
    );
  }

  void _startHeartbeat({
    required String intent,
    required ProfileModel? profile,
    required List<String> tags,
  }) {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 8), (_) async {
      if (_myUserId == null || Firebase.apps.isEmpty) {
        return;
      }

      final position = await _ensureAndGetPosition();
      if (position != null) {
        _myLatitude = position.latitude;
        _myLongitude = position.longitude;
      }

      final lat = _myLatitude ?? 19.0760;
      final lng = _myLongitude ?? 72.8777;

      final distanceKm = (_myLatitude != null && _myLongitude != null)
          ? 0.0
          : 0.3;

      final payload = {
        'userId': _myUserId,
        'name': (profile?.fullName.isNotEmpty ?? false)
            ? profile!.fullName
            : 'You',
        'age': profile?.age ?? 0,
        'intent': intent,
        'tags': tags,
        'latitude': lat,
        'longitude': lng,
        'distanceKm': distanceKm,
        'isLive': true,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      await FirebaseFirestore.instance
          .collection(_liveCollection)
          .doc(_myUserId)
          .set(payload, SetOptions(merge: true));

      await FirebaseFirestore.instance
          .collection(_usersCollection)
          .doc(_myUserId)
          .set(payload, SetOptions(merge: true));

      // Update distance values for all live users relative to current user.
      if (_myLatitude != null && _myLongitude != null) {
        final liveSnapshot = await FirebaseFirestore.instance
            .collection(_liveCollection)
            .where('isLive', isEqualTo: true)
            .get();

        final batch = FirebaseFirestore.instance.batch();
        for (final doc in liveSnapshot.docs) {
          final data = doc.data();
          final uLat = (data['latitude'] as num?)?.toDouble();
          final uLng = (data['longitude'] as num?)?.toDouble();
          if (uLat == null || uLng == null) {
            continue;
          }
          final distance = _distanceKmBetween(
            fromLat: _myLatitude!,
            fromLng: _myLongitude!,
            toLat: uLat,
            toLng: uLng,
          );
          batch.set(
            doc.reference,
            {'distanceKm': distance},
            SetOptions(merge: true),
          );
        }
        await batch.commit();
      }

      notifyListeners();
    });
  }
}
