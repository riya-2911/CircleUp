import 'dart:convert';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/user_post_model.dart';
import '../services/database_helper.dart';

class PostProvider with ChangeNotifier {
  static const String _postPayloadKey = 'userPostPayload';
  static const String _postsCollection = 'posts';

  final List<UserPostModel> _posts = <UserPostModel>[];
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _postsSubscription;

  List<UserPostModel> get posts => List<UserPostModel>.unmodifiable(_posts);

  Future<void> loadPosts() async {
    await DatabaseHelper.instance.ensurePostsTable();

    // Load local cache first for instant UI.
    final db = await DatabaseHelper.instance.database;
    final result = await db.query('posts', orderBy: 'createdAt DESC');
    _posts
      ..clear()
      ..addAll(result.map((e) => UserPostModel.fromMap(e)));
    notifyListeners();

    _startGlobalPostsListener();
  }

  Future<void> addPost({
    required String userId,
    required String authorName,
    required String content,
  }) async {
    await DatabaseHelper.instance.ensurePostsTable();
    final post = UserPostModel(
      id: 'post_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      authorName: authorName,
      content: content,
      createdAt: DateTime.now(),
      likesCount: 0,
      commentsCount: 0,
      isLiked: false,
      isCommented: false,
      likedByUserIds: const <String>[],
    );
    final db = await DatabaseHelper.instance.database;
    await db.insert('posts', post.toMap());
    _posts.insert(0, post);
    notifyListeners();

    // Best-effort cloud sync so all users can see the post.
    if (Firebase.apps.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection(_postsCollection)
            .doc(post.id)
            .set(post.toCloudMap());
      } catch (e) {
        debugPrint('Cloud post sync failed: $e');
      }
    }
  }

  List<UserPostModel> postsByUser(String userId) {
    return _posts.where((p) => p.userId == userId).toList();
  }

  Future<void> toggleLike(String postId, String actorUserId) async {
    if (actorUserId.isEmpty) return;

    final index = _posts.indexWhere((post) => post.id == postId);
    if (index == -1) return;

    final current = _posts[index];
    final likedBy = List<String>.from(current.likedByUserIds);
    final hasLiked = likedBy.contains(actorUserId);

    if (hasLiked) {
      likedBy.remove(actorUserId);
    } else {
      likedBy.add(actorUserId);
    }

    final nextCount = likedBy.length;

    await _updatePost(
      index,
      current.copyWith(
        likesCount: nextCount,
        likedByUserIds: likedBy,
      ),
    );
  }

  Future<void> toggleComment(String postId) async {
    final index = _posts.indexWhere((post) => post.id == postId);
    if (index == -1) return;

    final current = _posts[index];
    final nextCommented = !current.isCommented;
    final nextCount = nextCommented
        ? current.commentsCount + 1
        : (current.commentsCount > 0 ? current.commentsCount - 1 : 0);

    await _updatePost(
      index,
      current.copyWith(
        isCommented: nextCommented,
        commentsCount: nextCount,
      ),
    );
  }

  Future<void> deletePost(String postId) async {
    final index = _posts.indexWhere((post) => post.id == postId);
    if (index == -1) return;

    _posts.removeAt(index);
    notifyListeners();

    await DatabaseHelper.instance.ensurePostsTable();
    final db = await DatabaseHelper.instance.database;
    await db.delete(
      'posts',
      where: 'id = ?',
      whereArgs: [postId],
    );

    if (Firebase.apps.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection(_postsCollection)
            .doc(postId)
            .delete();
      } catch (e) {
        debugPrint('Cloud post delete sync failed: $e');
      }
    }
  }

  Future<void> _persist() async {
    final payload = jsonEncode(_posts.map((post) => post.toMap()).toList());
  }

  Future<void> _updatePost(int index, UserPostModel updated) async {
    _posts[index] = updated;
    notifyListeners();

    await DatabaseHelper.instance.ensurePostsTable();
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'posts',
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [updated.id],
    );

    if (Firebase.apps.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection(_postsCollection)
            .doc(updated.id)
            .set(updated.toCloudMap(), SetOptions(merge: true));
      } catch (e) {
        debugPrint('Cloud post update sync failed: $e');
      }
    }
  }

  void _startGlobalPostsListener() {
    if (Firebase.apps.isEmpty || _postsSubscription != null) {
      return;
    }

    _postsSubscription = FirebaseFirestore.instance
        .collection(_postsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
      (snapshot) async {
        final remotePosts = snapshot.docs
            .map((doc) {
              final data = doc.data();
              data['id'] = (data['id'] as String?)?.isNotEmpty == true
                  ? data['id']
                  : doc.id;
              return UserPostModel.fromMap(data);
            })
            .toList();

        _posts
          ..clear()
          ..addAll(remotePosts);
        notifyListeners();

        // Keep sqflite as local cache for offline/fast startup.
        await DatabaseHelper.instance.ensurePostsTable();
        final db = await DatabaseHelper.instance.database;
        final batch = db.batch();
        batch.delete('posts');
        for (final post in remotePosts) {
          batch.insert('posts', post.toMap());
        }
        await batch.commit(noResult: true);
      },
      onError: (error) {
        debugPrint('Global posts listener error: $error');
      },
    );
  }

  @override
  void dispose() {
    _postsSubscription?.cancel();
    super.dispose();
  }
}
