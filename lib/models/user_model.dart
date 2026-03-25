class UserModel {
  final String id;
  final String name;
  final String? profileImageUrl;
  final String? bio;

  UserModel({
    required this.id,
    required this.name,
    this.profileImageUrl,
    this.bio,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'profileImageUrl': profileImageUrl,
      'bio': bio,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      profileImageUrl: map['profileImageUrl'],
      bio: map['bio'],
    );
  }
}
