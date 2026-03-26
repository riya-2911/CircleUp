class UserPostModel {
  final String id;
  final String userId;
  final String authorName;
  final String content;
  final DateTime createdAt;

  UserPostModel({
    required this.id,
    required this.userId,
    required this.authorName,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'authorName': authorName,
      'content': content,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory UserPostModel.fromMap(Map<String, dynamic> map) {
    return UserPostModel(
      id: map['id'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      authorName: map['authorName'] as String? ?? 'User',
      content: map['content'] as String? ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['createdAt'] as int? ?? 0,
      ),
    );
  }
}
