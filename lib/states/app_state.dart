import 'package:flutter/foundation.dart';

enum AppStatus {
  unknown,
  unauthenticated,
  authenticated,
  onboarding,
  profileIncomplete,
}

class AppState extends ChangeNotifier {
  AppStatus _status = AppStatus.unauthenticated;

  AppStatus get status => _status;

  // --- Auth Flow ---
  void login() {
    // Suppose user logs in but still needs onboarding
    _status = AppStatus.onboarding;
    notifyListeners();
  }

  void logout() {
    _status = AppStatus.unauthenticated;
    notifyListeners();
  }

  // --- Onboarding Flow ---
  void completeOnboarding() {
    // After onboarding, maybe user has incomplete profile
    _status = AppStatus.profileIncomplete;
    notifyListeners();
  }

  // --- Profile Flow ---
  void completeProfile() {
    _status = AppStatus.authenticated;
    notifyListeners();
  }

  // --- Utility ---
  void setUnknown() {
    _status = AppStatus.unknown;
    notifyListeners();
  }
}
