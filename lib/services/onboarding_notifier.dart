import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String kOnboardingCompleteKey = 'onboarding_complete';

/// Persists and broadcasts first-launch onboarding completion.
class OnboardingNotifier extends ChangeNotifier {
  bool _isLoaded = false;
  bool _isComplete = false;

  bool get isLoaded => _isLoaded;
  bool get isComplete => _isComplete;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _isComplete = prefs.getBool(kOnboardingCompleteKey) ?? false;
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> markComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kOnboardingCompleteKey, true);
    _isComplete = true;
    notifyListeners();
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kOnboardingCompleteKey, false);
    _isComplete = false;
    notifyListeners();
  }
}
