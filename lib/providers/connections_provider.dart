import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/live_user_model.dart';

class ConnectionRequestItem {
  const ConnectionRequestItem({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderAge,
    required this.senderTags,
    required this.receiverId,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String senderId;
  final String senderName;
  final int senderAge;
  final List<String> senderTags;
  final String receiverId;
  final String status;
  final DateTime createdAt;

  factory ConnectionRequestItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final rawTags = data['senderTags'];
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
      senderTags: rawTags is List ? rawTags.map((e) => e.toString()).toList() : <String>[],
      receiverId: (data['receiverId'] as String?) ?? '',
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

  final List<ConnectionRequestItem> _incomingRequests = <ConnectionRequestItem>[];
  final List<ConnectionItem> _connections = <ConnectionItem>[];

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _incomingRequestsSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _connectionsSub;

  List<ConnectionRequestItem> get incomingRequests =>
      List<ConnectionRequestItem>.unmodifiable(_incomingRequests);
  List<ConnectionItem> get connections => List<ConnectionItem>.unmodifiable(_connections);
  int get connectionCount => _connections.length;

  Future<void> ensureForUser({required String userId, required String userName}) async {
    if (userId.isEmpty) return;
    if (_currentUserId == userId && _incomingRequestsSub != null && _connectionsSub != null) {
      return;
    }

    _currentUserId = userId;
    _currentUserName = userName;

    await _incomingRequestsSub?.cancel();
    await _connectionsSub?.cancel();

    _incomingRequestsSub = FirebaseFirestore.instance
        .collection(_requestsCollection)
        .where('receiverId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snapshot) {
      final list = snapshot.docs.map(ConnectionRequestItem.fromDoc).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _incomingRequests
        ..clear()
        ..addAll(list);
      notifyListeners();
    });

    _connectionsSub = FirebaseFirestore.instance
        .collection(_connectionsCollection)
        .where('participants', arrayContains: userId)
        .snapshots()
        .listen((snapshot) {
      final list = snapshot.docs.map(ConnectionItem.fromDoc).toList();
      list.sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
      _connections
        ..clear()
        ..addAll(list);
      notifyListeners();
    });
  }

  Future<bool> sendConnectionRequest({
    required String senderId,
    required String senderName,
    required int senderAge,
    required List<String> senderTags,
    required LiveUserModel target,
  }) async {
    if (senderId.isEmpty || target.userId.isEmpty || senderId == target.userId) {
      return false;
    }

    final existing = await FirebaseFirestore.instance
        .collection(_requestsCollection)
        .where('senderId', isEqualTo: senderId)
        .where('receiverId', isEqualTo: target.userId)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      return true;
    }

    final requestId = '${senderId}_${target.userId}';
    await FirebaseFirestore.instance.collection(_requestsCollection).doc(requestId).set({
      'senderId': senderId,
      'senderName': senderName,
      'senderAge': senderAge,
      'senderTags': senderTags,
      'receiverId': target.userId,
      'receiverName': target.name,
      'receiverAge': target.age,
      'receiverTags': target.tags,
      'status': 'pending',
      'createdAt': Timestamp.fromDate(DateTime.now()),
    }, SetOptions(merge: true));

    return true;
  }

  Future<void> acceptRequest(ConnectionRequestItem request) async {
    final currentUserId = _currentUserId;
    if (currentUserId == null || currentUserId.isEmpty) return;

    final requestRef = FirebaseFirestore.instance.collection(_requestsCollection).doc(request.id);

    final sorted = <String>[request.senderId, request.receiverId]..sort();
    final userAId = sorted[0];
    final userBId = sorted[1];

    final userAName = userAId == request.senderId ? request.senderName : (_currentUserName ?? 'You');
    final userBName = userBId == request.senderId ? request.senderName : (_currentUserName ?? 'You');

    final connectionId = '${userAId}_$userBId';
    final connectionRef = FirebaseFirestore.instance.collection(_connectionsCollection).doc(connectionId);

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
  }

  Future<void> rejectRequest(ConnectionRequestItem request) async {
    await FirebaseFirestore.instance
        .collection(_requestsCollection)
        .doc(request.id)
        .set({'status': 'rejected'}, SetOptions(merge: true));
  }

  Future<void> sendMessage({
    required String connectionId,
    required String senderId,
    required String text,
  }) async {
    if (text.trim().isEmpty) return;

    final msg = text.trim();
    final connectionRef = FirebaseFirestore.instance.collection(_connectionsCollection).doc(connectionId);
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

  @override
  void dispose() {
    _incomingRequestsSub?.cancel();
    _connectionsSub?.cancel();
    super.dispose();
  }
}
