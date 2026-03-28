class UserPostModel {
  final String id;
  final String userId;
  final String authorName;
  final String content;
  final DateTime createdAt;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final bool isCommented;
  final List<String> likedByUserIds;

  UserPostModel({
    required this.id,
    required this.userId,
    required this.authorName,
    required this.content,
    required this.createdAt,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isLiked = false,
    this.isCommented = false,
    this.likedByUserIds = const <String>[],
  });

  UserPostModel copyWith({
    String? id,
    String? userId,
    String? authorName,
    String? content,
    DateTime? createdAt,
    int? likesCount,
    int? commentsCount,
    bool? isLiked,
    bool? isCommented,
    List<String>? likedByUserIds,
  }) {
    return UserPostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      authorName: authorName ?? this.authorName,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLiked: isLiked ?? this.isLiked,
      isCommented: isCommented ?? this.isCommented,
      likedByUserIds: likedByUserIds ?? this.likedByUserIds,
    );
  }

  bool isLikedBy(String userId) {
    if (userId.isEmpty) return false;
    return likedByUserIds.contains(userId);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'authorName': authorName,
      'content': content,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'isLiked': isLiked ? 1 : 0,
      'isCommented': isCommented ? 1 : 0,
      'likedByUserIdsCsv': likedByUserIds.join(','),
    };
  }

  Map<String, dynamic> toCloudMap() {
    return {
      'id': id,
      'userId': userId,
      'authorName': authorName,
      'content': content,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'isLiked': isLiked,
      'isCommented': isCommented,
      'likedByUserIds': likedByUserIds,
    };
  }

  factory UserPostModel.fromMap(Map<String, dynamic> map) {
    final createdRaw = map['createdAt'];
    final createdMillis = createdRaw is int
        ? createdRaw
        : createdRaw is num
            ? createdRaw.toInt()
            : int.tryParse(createdRaw?.toString() ?? '') ?? 0;
    final likedByUserIds = _toStringList(
      map['likedByUserIds'] ?? map['likedByUserIdsCsv'],
    );
    final likeCountFromList = likedByUserIds.length;
    final likeCountFromField = _toInt(map['likesCount']);
    final resolvedLikesCount = likeCountFromList > 0
        ? likeCountFromList
        : likeCountFromField;

    return UserPostModel(
      id: map['id'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      authorName: map['authorName'] as String? ?? 'User',
      content: map['content'] as String? ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        createdMillis,
      ),
      likesCount: resolvedLikesCount,
      commentsCount: _toInt(map['commentsCount']),
      isLiked: _toBool(map['isLiked']),
      isCommented: _toBool(map['isCommented']),
      likedByUserIds: likedByUserIds,
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is num) return value.toInt() == 1;
    final normalized = value?.toString().toLowerCase() ?? '';
    return normalized == 'true' || normalized == '1';
  }

  static List<String> _toStringList(dynamic value) {
    if (value is List) {
      return value
          .map((item) => item.toString())
          .where((item) => item.isNotEmpty)
          .toSet()
          .toList();
    }

    if (value is String) {
      if (value.trim().isEmpty) return <String>[];
      return value
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toSet()
          .toList();
    }

    return <String>[];
  }
}
