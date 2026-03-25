import 'package:flutter/foundation.dart';
import '../models/intent_model.dart';
import '../services/prefs_helper.dart';

class IntentProvider with ChangeNotifier {
  IntentModel? _currentIntent;

  IntentModel? get currentIntent => _currentIntent;

  final List<IntentModel> availableIntents = [
    IntentModel(id: 'i1', title: 'Study', iconName: 'menu_book', description: 'Looking for a study partner'),
    IntentModel(id: 'i2', title: 'Startup', iconName: 'rocket_launch', description: 'Want to build something together'),
    IntentModel(id: 'i3', title: 'Fitness', iconName: 'fitness_center', description: 'Looking for a workout buddy'),
    IntentModel(id: 'i4', title: 'Travel', iconName: 'flight_takeoff', description: 'Exploring the city'),
    IntentModel(id: 'i5', title: 'Hangout', iconName: 'local_cafe', description: 'Just want to grab a coffee'),
  ];

  Future<void> loadSavedIntent() async {
    final intentId = await PrefsHelper.getCurrentIntent();
    if (intentId != null) {
      try {
        _currentIntent = availableIntents.firstWhere((i) => i.id == intentId);
      } catch (e) {
        _currentIntent = null;
      }
      notifyListeners();
    }
  }

  Future<void> selectIntent(IntentModel intent) async {
    _currentIntent = intent;
    await PrefsHelper.saveCurrentIntent(intent.id);
    notifyListeners();
  }

  void clearIntent() {
    _currentIntent = null;
    PrefsHelper.saveCurrentIntent('');
    notifyListeners();
  }
}
