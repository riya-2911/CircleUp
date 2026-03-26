class ProfileModel {
  final String userId;
  final String fullName;
  final String gender;
  final int age;
  final String personality;
  final String city;
  final String collegeOrProfession;
  final String shortBio;
  final List<String> interests;
  final String? photoPath;
  final int updatedAt;

  ProfileModel({
    required this.userId,
    required this.fullName,
    required this.gender,
    required this.age,
    required this.personality,
    required this.city,
    required this.collegeOrProfession,
    required this.shortBio,
    required this.interests,
    this.photoPath,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'fullName': fullName,
      'gender': gender,
      'age': age,
      'personality': personality,
      'city': city,
      'collegeOrProfession': collegeOrProfession,
      'shortBio': shortBio,
      'interests': interests.join(','),
      'photoPath': photoPath,
      'updatedAt': updatedAt,
    };
  }

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    final interestsCsv = map['interests'] as String? ?? '';
    return ProfileModel(
      userId: map['userId'] as String,
      fullName: map['fullName'] as String? ?? '',
      gender: map['gender'] as String? ?? '',
      age: map['age'] as int? ?? 0,
      personality: map['personality'] as String? ?? '',
      city: map['city'] as String? ?? '',
      collegeOrProfession: map['collegeOrProfession'] as String? ?? '',
      shortBio: map['shortBio'] as String? ?? '',
      interests: interestsCsv.isEmpty
          ? <String>[]
          : interestsCsv
              .split(',')
              .where((value) => value.trim().isNotEmpty)
              .map((value) => value.trim())
              .toList(),
      photoPath: map['photoPath'] as String?,
      updatedAt: map['updatedAt'] as int? ?? 0,
    );
  }
}