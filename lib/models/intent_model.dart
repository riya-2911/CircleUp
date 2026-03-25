class IntentModel {
  final String id;
  final String title;
  final String iconName; // e.g., 'book' for study
  final String description;

  IntentModel({
    required this.id,
    required this.title,
    required this.iconName,
    required this.description,
  });
}

class UserIntent {
  final String userId;
  final String intentId;
  final double latitude;
  final double longitude;
  final DateTime updatedAt;

  UserIntent({
    required this.userId,
    required this.intentId,
    required this.latitude,
    required this.longitude,
    required this.updatedAt,
  });
}
