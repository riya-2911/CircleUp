import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/live_user_model.dart';
import '../services/auth_service.dart';
import '../services/prefs_helper.dart';

class ConnectionRequestItem {
  const ConnectionRequestItem({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderAge,
    required this.senderTags,
    required this.receiverId,
    required this.receiverName,
    required this.receiverAge,
    required this.receiverTags,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String senderId;
  final String senderName;
  final int senderAge;
  final List<String> senderTags;
  final String receiverId;
  final String receiverName;
  final int receiverAge;
  final List<String> receiverTags;
  final String status;
  final DateTime createdAt;

  factory ConnectionRequestItem.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    final rawTags = data['senderTags'];
    final rawReceiverTags = data['receiverTags'];
    final rawCreatedAt = data['createdAt'];

    DateTime createdAt = DateTime.now();
    if (rawCreatedAt is Timestamp) {
      createdAt = rawCreatedAt.toDate();
    }

    return ConnectionRequestItem(
      id: doc.id,
      senderId: (data['senderId'] as String?) ?? '',
      senderName: (data['senderName'] as String?) ?? 'Unknown',
      senderAge: ((data['senderAge'] as num?) ?? 0).toInt(),
      senderTags: rawTags is List
          ? rawTags.map((e) => e.toString()).toList()
          : <String>[],
      receiverId: (data['receiverId'] as String?) ?? '',
      receiverName: (data['receiverName'] as String?) ?? 'Unknown',
      receiverAge: ((data['receiverAge'] as num?) ?? 0).toInt(),
      receiverTags: rawReceiverTags is List
          ? rawReceiverTags.map((e) => e.toString()).toList()
          : <String>[],
      status: (data['status'] as String?) ?? 'pending',
      createdAt: createdAt,
    );
  }
}

class ConnectionItem {
  const ConnectionItem({
    required this.id,
    required this.userAId,
    required this.userAName,
    required this.userBId,
    required this.userBName,
    required this.lastMessage,
    required this.lastUpdated,
  });

  final String id;
  final String userAId;
  final String userAName;
  final String userBId;
  final String userBName;
  final String lastMessage;
  final DateTime lastUpdated;

  String partnerNameFor(String currentUserId) {
    return currentUserId == userAId ? userBName : userAName;
  }

  String partnerIdFor(String currentUserId) {
    return currentUserId == userAId ? userBId : userAId;
  }

  factory ConnectionItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final rawUpdated = data['lastUpdated'];

    DateTime updated = DateTime.now();
    if (rawUpdated is Timestamp) {
      updated = rawUpdated.toDate();
    }

    return ConnectionItem(
      id: doc.id,
      userAId: (data['userAId'] as String?) ?? '',
      userAName: (data['userAName'] as String?) ?? 'Unknown',
      userBId: (data['userBId'] as String?) ?? '',
      userBName: (data['userBName'] as String?) ?? 'Unknown',
      lastMessage: (data['lastMessage'] as String?) ?? '',
      lastUpdated: updated,
    );
  }
}

class ConnectionsProvider with ChangeNotifier {
  static const String _requestsCollection = 'connection_requests';
  static const String _connectionsCollection = 'connections';

  String? _currentUserId;
  String? _currentUserName;
  String? _lastRequestError;

  final List<ConnectionRequestItem> _incomingRequests =
      <ConnectionRequestItem>[];
  final List<ConnectionRequestItem> _outgoingRequests =
      <ConnectionRequestItem>[];
  final List<ConnectionItem> _connections = <ConnectionItem>[];

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _incomingRequestsSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _outgoingRequestsSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _connectionsSub;

  List<ConnectionRequestItem> get incomingRequests =>
      List<ConnectionRequestItem>.unmodifiable(_incomingRequests);
  List<ConnectionRequestItem> get outgoingRequests =>
      List<ConnectionRequestItem>.unmodifiable(_outgoingRequests);
  List<ConnectionItem> get connections =>
      List<ConnectionItem>.unmodifiable(_connections);
  String get currentUserId => _currentUserId ?? '';
  String? get lastRequestError => _lastRequestError;
  int get connectionCount => _connections.length;

  Future<String> _resolveCanonicalUserId(String fallbackUserId) async {
    var authUser = FirebaseAuth.instance.currentUser;
    if (authUser == null) {
      final ok = await AuthService.signInAnonymously();
      if (ok) {
        authUser = FirebaseAuth.instance.currentUser;
      }
    }

    final canonical = authUser?.uid;
    if (canonical != null && canonical.isNotEmpty) {
      final saved = await PrefsHelper.getUserId();
      if (saved != canonical) {
        await PrefsHelper.saveUserId(canonical);
      }
      return canonical;
    }
    return fallbackUserId;
  }

  Future<void> _refreshPendingRequestsForUser(String userId) async {
    final incomingSnap = await FirebaseFirestore.instance
        .collection(_requestsCollection)
        .where('receiverId', isEqualTo: userId)
        .get();
    final incomingList =
        incomingSnap.docs
            .map(ConnectionRequestItem.fromDoc)
            .where((item) => item.status == 'pending')
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final outgoingSnap = await FirebaseFirestore.instance
        .collection(_requestsCollection)
        .where('senderId', isEqualTo: userId)
        .get();
    final outgoingList =
        outgoingSnap.docs
            .map(ConnectionRequestItem.fromDoc)
            .where((item) => item.status == 'pending')
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    _incomingRequests
      ..clear()
      ..addAll(incomingList);
    _outgoingRequests
      ..clear()
      ..addAll(outgoingList);
    notifyListeners();
  }

  Future<void> ensureForUser({
    required String userId,
    required String userName,
  }) async {
    if (userId.isEmpty) return;
    final effectiveUserId = await _resolveCanonicalUserId(userId);
    if (_currentUserId == effectiveUserId &&
        _incomingRequestsSub != null &&
        _outgoingRequestsSub != null &&
        _connectionsSub != null) {
      return;
    }

    _currentUserId = effectiveUserId;
    _currentUserName = userName;

    await _incomingRequestsSub?.cancel();
    await _outgoingRequestsSub?.cancel();
    await _connectionsSub?.cancel();

    _incomingRequestsSub = FirebaseFirestore.instance
        .collection(_requestsCollection)
        .where('receiverId', isEqualTo: effectiveUserId)
        .snapshots()
        .listen(
          (snapshot) {
            final list = snapshot.docs
                .map(ConnectionRequestItem.fromDoc)
                .where((item) => item.status == 'pending')
                .toList();
            list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            _incomingRequests
              ..clear()
              ..addAll(list);
            notifyListeners();
          },
          onError: (Object error, StackTrace stackTrace) {
            debugPrint('Incoming requests stream error: $error');
          },
        );

    _outgoingRequestsSub = FirebaseFirestore.instance
        .collection(_requestsCollection)
        .where('senderId', isEqualTo: effectiveUserId)
        .snapshots()
        .listen(
          (snapshot) {
            final list = snapshot.docs
                .map(ConnectionRequestItem.fromDoc)
                .where((item) => item.status == 'pending')
                .toList();
            list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            _outgoingRequests
              ..clear()
              ..addAll(list);
            notifyListeners();
          },
          onError: (Object error, StackTrace stackTrace) {
            debugPrint('Outgoing requests stream error: $error');
          },
        );

    _connectionsSub = FirebaseFirestore.instance
        .collection(_connectionsCollection)
        .where('participants', arrayContains: effectiveUserId)
        .snapshots()
        .listen(
          (snapshot) {
            final list = snapshot.docs.map(ConnectionItem.fromDoc).toList();
            list.sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
            _connections
              ..clear()
              ..addAll(list);
            notifyListeners();
          },
          onError: (Object error, StackTrace stackTrace) {
            debugPrint('Connections stream error: $error');
          },
        );

    unawaited(_refreshPendingRequestsForUser(effectiveUserId));
  }

  Future<bool> sendConnectionRequest({
    required String senderId,
    required String senderName,
    required int senderAge,
    required List<String> senderTags,
    required LiveUserModel target,
  }) async {
    _lastRequestError = null;
    final effectiveSenderId = await _resolveCanonicalUserId(senderId);

    if (effectiveSenderId.isEmpty) {
      _lastRequestError = 'Authentication missing. Please sign in again.';
      return false;
    }

    if (target.userId.isEmpty) {
      _lastRequestError =
          'Target user is unavailable. Please refresh and try again.';
      return false;
    }

    if (effectiveSenderId == target.userId) {
      _lastRequestError = 'You cannot send a request to yourself.';
      return false;
    }

    try {
      // Avoid fixed IDs: updating an old request to "pending" can be denied by rules.
      final senderRequestsSnap = await FirebaseFirestore.instance
          .collection(_requestsCollection)
          .where('senderId', isEqualTo: effectiveSenderId)
          .get();
      final existingPending = senderRequestsSnap.docs
          .map(ConnectionRequestItem.fromDoc)
          .where(
            (item) =>
                item.receiverId == target.userId && item.status == 'pending',
          )
          .toList();
      if (existingPending.isNotEmpty) {
        final existingRequest = existingPending.first;
        _outgoingRequests.removeWhere((item) => item.id == existingRequest.id);
        _outgoingRequests.insert(0, existingRequest);
        notifyListeners();
        return true;
      }

      final requestRef = FirebaseFirestore.instance
          .collection(_requestsCollection)
          .doc();
      final requestId = requestRef.id;

      final now = DateTime.now();
      await requestRef.set({
        'senderId': effectiveSenderId,
        'senderName': senderName,
        'senderAge': senderAge,
        'senderTags': senderTags,
        'receiverId': target.userId,
        'receiverName': target.name,
        'receiverAge': target.age,
        'receiverTags': target.tags,
        'status': 'pending',
        'createdAt': Timestamp.fromDate(now),
      });

      final createdRequest = ConnectionRequestItem(
        id: requestId,
        senderId: effectiveSenderId,
        senderName: senderName,
        senderAge: senderAge,
        senderTags: senderTags,
        receiverId: target.userId,
        receiverName: target.name,
        receiverAge: target.age,
        receiverTags: target.tags,
        status: 'pending',
        createdAt: now,
      );
      _outgoingRequests.removeWhere((item) => item.id == requestId);
      _outgoingRequests.insert(0, createdRequest);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('sendConnectionRequest failed: $e');
      if (e is FirebaseException) {
        if (e.code == 'permission-denied') {
          _lastRequestError =
              'Permission denied by Firebase rules. Check auth/rules.';
        } else {
          _lastRequestError = 'Request failed: ${e.code}';
        }
      } else {
        _lastRequestError = 'Request failed. Please try again.';
      }
      return false;
    }
  }

  Future<void> acceptRequest(ConnectionRequestItem request) async {
    final currentUserId = _currentUserId;
    if (currentUserId == null || currentUserId.isEmpty) return;

    final requestRef = FirebaseFirestore.instance
        .collection(_requestsCollection)
        .doc(request.id);

    final sorted = <String>[request.senderId, request.receiverId]..sort();
    final userAId = sorted[0];
    final userBId = sorted[1];

    final userAName = userAId == request.senderId
        ? request.senderName
        : (_currentUserName ?? 'You');
    final userBName = userBId == request.senderId
        ? request.senderName
        : (_currentUserName ?? 'You');

    final connectionId = '${userAId}_$userBId';
    final connectionRef = FirebaseFirestore.instance
        .collection(_connectionsCollection)
        .doc(connectionId);

    final batch = FirebaseFirestore.instance.batch();
    batch.set(requestRef, {'status': 'accepted'}, SetOptions(merge: true));
    batch.set(connectionRef, {
      'participants': <String>[userAId, userBId],
      'userAId': userAId,
      'userAName': userAName,
      'userBId': userBId,
      'userBName': userBName,
      'lastMessage': 'Connected',
      'lastUpdated': Timestamp.fromDate(DateTime.now()),
      'createdAt': Timestamp.fromDate(DateTime.now()),
    }, SetOptions(merge: true));

    await batch.commit();
    _incomingRequests.removeWhere((item) => item.id == request.id);
    _outgoingRequests.removeWhere((item) => item.id == request.id);
    notifyListeners();
  }

  Future<void> rejectRequest(ConnectionRequestItem request) async {
    await FirebaseFirestore.instance
        .collection(_requestsCollection)
        .doc(request.id)
        .set({'status': 'rejected'}, SetOptions(merge: true));
    _incomingRequests.removeWhere((item) => item.id == request.id);
    _outgoingRequests.removeWhere((item) => item.id == request.id);
    notifyListeners();
  }

  Future<void> cancelRequest(ConnectionRequestItem request) async {
    await FirebaseFirestore.instance
        .collection(_requestsCollection)
        .doc(request.id)
        .set({'status': 'cancelled'}, SetOptions(merge: true));
    _incomingRequests.removeWhere((item) => item.id == request.id);
    _outgoingRequests.removeWhere((item) => item.id == request.id);
    notifyListeners();
  }

  Future<void> sendMessage({
    required String connectionId,
    required String senderId,
    required String text,
  }) async {
    if (text.trim().isEmpty) return;

    final msg = text.trim();
    final connectionRef = FirebaseFirestore.instance
        .collection(_connectionsCollection)
        .doc(connectionId);
    final msgRef = connectionRef.collection('messages').doc();

    final batch = FirebaseFirestore.instance.batch();
    batch.set(msgRef, {
      'senderId': senderId,
      'text': msg,
      'createdAt': Timestamp.fromDate(DateTime.now()),
    });
    batch.set(connectionRef, {
      'lastMessage': msg,
      'lastUpdated': Timestamp.fromDate(DateTime.now()),
    }, SetOptions(merge: true));
    await batch.commit();
  }

  Future<void> removeConnection(String connectionId) async {
    if (connectionId.isEmpty) return;
    await FirebaseFirestore.instance
        .collection(_connectionsCollection)
        .doc(connectionId)
        .delete();
  }

  @override
  void dispose() {
    _incomingRequestsSub?.cancel();
    _outgoingRequestsSub?.cancel();
    _connectionsSub?.cancel();
    super.dispose();
  }
}
