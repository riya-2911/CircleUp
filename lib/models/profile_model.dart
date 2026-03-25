class ProfileModel {
  final String userId;
  final String fullName;
  final String collegeOrProfession;
  final String shortBio;
  final List<String> interests;
  final String? photoPath;
  final int updatedAt;

  ProfileModel({
    required this.userId,
    required this.fullName,
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