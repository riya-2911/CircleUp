import 'package:cloud_firestore/cloud_firestore.dart';

class LiveUserModel {
  const LiveUserModel({
    required this.userId,
    required this.name,
    required this.age,
    required this.intent,
    required this.tags,
    required this.latitude,
    required this.longitude,
    required this.distanceKm,
    required this.isLive,
    required this.updatedAt,
  });

  final String userId;
  final String name;
  final int age;
  final String intent;
  final List<String> tags;
  final double latitude;
  final double longitude;
  final double distanceKm;
  final bool isLive;
  final DateTime updatedAt;

  bool get isStale => DateTime.now().difference(updatedAt).inMinutes > 2;

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'age': age,
      'intent': intent,
      'tags': tags,
      'latitude': latitude,
      'longitude': longitude,
      'distanceKm': distanceKm,
      'isLive': isLive,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory LiveUserModel.fromMap(Map<String, dynamic> map) {
    final tagsRaw = map['tags'];
    final updatedAtRaw = map['updatedAt'];

    DateTime parsedUpdatedAt = DateTime.now();
    if (updatedAtRaw is Timestamp) {
      parsedUpdatedAt = updatedAtRaw.toDate();
    } else if (updatedAtRaw is int) {
      parsedUpdatedAt = DateTime.fromMillisecondsSinceEpoch(updatedAtRaw);
    }

    return LiveUserModel(
      userId: (map['userId'] as String?) ?? '',
      name: (map['name'] as String?) ?? 'Unknown',
      age: (map['age'] as int?) ?? 0,
      intent: (map['intent'] as String?) ?? 'Live',
      tags: tagsRaw is List
          ? tagsRaw.map((e) => e.toString()).toList()
          : <String>[],
        latitude: ((map['latitude'] as num?) ?? 0).toDouble(),
        longitude: ((map['longitude'] as num?) ?? 0).toDouble(),
      distanceKm: ((map['distanceKm'] as num?) ?? 0.3).toDouble(),
      isLive: (map['isLive'] as bool?) ?? false,
      updatedAt: parsedUpdatedAt,
    );
  }
}
