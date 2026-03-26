import 'package:flutter/foundation.dart';
import '../models/profile_model.dart';
import '../services/database_helper.dart';
import '../services/prefs_helper.dart';
import 'dart:convert';

class ProfileProvider with ChangeNotifier {
  ProfileModel? _profile;

  ProfileModel? get profile => _profile;
  bool get hasProfile => _profile != null;

  // Getters for individual fields
  String get fullName => _profile?.fullName ?? 'Not Set';
  String get gender => _profile?.gender ?? 'Not Set';
  int get age => _profile?.age ?? 0;
  String get personality => _profile?.personality ?? 'Not Set';
  String get city => _profile?.city ?? 'Not Set';
  String get collegeOrProfession => _profile?.collegeOrProfession ?? 'Not Set';
  List<String> get interests => _profile?.interests ?? [];
  String? get photoPath => _profile?.photoPath;

  Future<void> loadProfile() async {
    try {
      final userId = await PrefsHelper.getUserId();
      if (userId == null || userId.isEmpty) {
        _profile = null;
        notifyListeners();
        return;
      }

      // Try to load from database first
      ProfileModel? existing;
      try {
        existing = await DatabaseHelper.instance.getUserProfile(userId);
      } catch (_) {
        // If database fails, try to load from prefs
        final payload = await PrefsHelper.getProfilePayload();
        if (payload != null && payload.isNotEmpty) {
          final decoded = jsonDecode(payload) as Map<String, dynamic>;
          existing = ProfileModel.fromMap(decoded);
        }
      }

      if (existing != null) {
        _profile = existing;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading profile: $e');
      notifyListeners();
    }
  }

  Future<void> saveProfile({
    required String fullName,
    required String gender,
    required int age,
    required String personality,
    required String city,
    required String collegeOrProfession,
    required List<String> interests,
    String? photoPath,
  }) async {
    try {
      String? userId = await PrefsHelper.getUserId();
      userId ??= 'local_${DateTime.now().millisecondsSinceEpoch}';

      await PrefsHelper.saveUserId(userId);
      await PrefsHelper.saveUserName(fullName);

      _profile = ProfileModel(
        userId: userId,
        fullName: fullName,
        gender: gender,
        age: age,
        personality: personality,
        city: city,
        collegeOrProfession: collegeOrProfession,
        shortBio: '',
        interests: interests,
        photoPath: photoPath,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );

      // Try DB write, but don't block user flow if local schema/plugin fails.
      try {
        await DatabaseHelper.instance.upsertUserProfile(_profile!);
      } catch (e) {
        debugPrint('Database profile save failed, using prefs fallback only: $e');
      }

      // Also save to prefs as backup
      final payload = jsonEncode(_profile!.toMap());
      await PrefsHelper.saveProfilePayload(payload);
      await PrefsHelper.setProfileSetupCompleted();

      notifyListeners();
    } catch (e) {
      debugPrint('Error saving profile: $e');
      rethrow;
    }
  }

  Future<void> updatePhotoPath(String? newPhotoPath) async {
    if (_profile == null) return;

    try {
      _profile = ProfileModel(
        userId: _profile!.userId,
        fullName: _profile!.fullName,
        gender: _profile!.gender,
        age: _profile!.age,
        personality: _profile!.personality,
        city: _profile!.city,
        collegeOrProfession: _profile!.collegeOrProfession,
        shortBio: _profile!.shortBio,
        interests: _profile!.interests,
        photoPath: newPhotoPath,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );

      await DatabaseHelper.instance.upsertUserProfile(_profile!);
      final payload = jsonEncode(_profile!.toMap());
      await PrefsHelper.saveProfilePayload(payload);

      notifyListeners();
    } catch (e) {
      debugPrint('Error updating photo: $e');
      rethrow;
    }
  }

  Future<void> clearProfile() async {
    _profile = null;
    notifyListeners();
  }
}
