import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/user_post_model.dart';
import '../services/database_helper.dart';

class PostProvider with ChangeNotifier {
  static const String _postPayloadKey = 'userPostPayload';

  final List<UserPostModel> _posts = <UserPostModel>[];

  List<UserPostModel> get posts => List<UserPostModel>.unmodifiable(_posts);

  Future<void> loadPosts() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query('posts', orderBy: 'createdAt DESC');
    _posts
      ..clear()
      ..addAll(result.map((e) => UserPostModel.fromMap(e)));
    notifyListeners();
  }

  Future<void> addPost({
    required String userId,
    required String authorName,
    required String content,
  }) async {
    final post = UserPostModel(
      id: 'post_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      authorName: authorName,
      content: content,
      createdAt: DateTime.now(),
    );
    final db = await DatabaseHelper.instance.database;
    await db.insert('posts', post.toMap());
    _posts.insert(0, post);
    notifyListeners();
  }

  List<UserPostModel> postsByUser(String userId) {
    return _posts.where((p) => p.userId == userId).toList();
  }

  Future<void> _persist() async {
    final payload = jsonEncode(_posts.map((post) => post.toMap()).toList());
    await PrefsHelper.saveCustomString(_postPayloadKey, payload);
  }
}
