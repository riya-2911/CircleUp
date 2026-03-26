import 'package:shared_preferences/shared_preferences.dart';

class PrefsHelper {
  static const String _keyUserId = 'userId';
  static const String _keyUserName = 'userName';
  static const String _keyCurrentIntent = 'currentIntent';
  static const String _keyCompletedOnboarding = 'completedOnboarding';
  static const String _keyCompletedProfileSetup = 'completedProfileSetup';
  static const String _keyProfilePayload = 'profilePayload';

  static Future<void> saveUserId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, id);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }

  static Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserName, name);
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName);
  }

  static Future<void> saveCurrentIntent(String intentId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCurrentIntent, intentId);
  }

  static Future<String?> getCurrentIntent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCurrentIntent);
  }

  static Future<void> setOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyCompletedOnboarding, true);
  }

  static Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyCompletedOnboarding) ?? false;
  }

  static Future<void> setProfileSetupCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyCompletedProfileSetup, true);
  }

  static Future<bool> hasCompletedProfileSetup() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyCompletedProfileSetup) ?? false;
  }

  static Future<void> saveProfilePayload(String payload) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyProfilePayload, payload);
  }

  static Future<String?> getProfilePayload() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyProfilePayload);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<void> saveCustomString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  static Future<String?> getCustomString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }
}
