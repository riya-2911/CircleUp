import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/prefs_helper.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  Future<void> checkLoginStatus() async {
    final userId = await PrefsHelper.getUserId();
    final userName = await PrefsHelper.getUserName();
    if (userId != null && userName != null) {
      _currentUser = UserModel(id: userId, name: userName);
      notifyListeners();
    }
  }

  Future<void> login(String name) async {
    // Mock login generating a random ID for offline testing
    final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    await PrefsHelper.saveUserId(userId);
    await PrefsHelper.saveUserName(name);
    _currentUser = UserModel(id: userId, name: name);
    notifyListeners();
  }

  Future<void> logout() async {
    await PrefsHelper.clearAll();
    _currentUser = null;
    notifyListeners();
  }
}
