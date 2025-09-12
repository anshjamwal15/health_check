import 'package:flutter/foundation.dart';
import 'package:health_check/utils/shared_prefrences.dart';

enum AppStatus {
  unknown,
  unauthenticated,
  authenticated,
  onboarding,
  profileIncomplete,
}

class AppState extends ChangeNotifier {
  AppStatus _status = AppStatus.unknown;
  Function(AppStatus)? _onStatusChanged;

  AppStatus get status => _status;

  /// Set callback for when status changes (used by UserState to sync to Firebase)
  void setStatusChangeCallback(Function(AppStatus) callback) {
    _onStatusChanged = callback;
  }

  /// Initialize app state from saved preferences
  Future<void> initializeFromStorage() async {
    final savedStatus = await SharedPreferencesUtil.getAppStatus();
    if (savedStatus != null) {
      _status = _parseAppStatus(savedStatus);
    } else {
      _status = AppStatus.unauthenticated;
    }
    notifyListeners();
  }

  /// Parse string to AppStatus enum
  AppStatus _parseAppStatus(String statusString) {
    switch (statusString) {
      case 'AppStatus.authenticated':
        return AppStatus.authenticated;
      case 'AppStatus.onboarding':
        return AppStatus.onboarding;
      case 'AppStatus.profileIncomplete':
        return AppStatus.profileIncomplete;
      case 'AppStatus.unauthenticated':
        return AppStatus.unauthenticated;
      default:
        return AppStatus.unknown;
    }
  }

  /// Save current status to storage and sync to Firebase
  Future<void> _saveStatus() async {
    await SharedPreferencesUtil.saveAppStatus(_status.toString());
    // Notify UserState to update Firebase
    if (_onStatusChanged != null) {
      _onStatusChanged!(_status);
    }
  }

  // --- Auth Flow ---
  Future<void> login() async {
    // Suppose user logs in but still needs onboarding
    _status = AppStatus.onboarding;
    await _saveStatus();
    notifyListeners();
  }

  Future<void> logout() async {
    _status = AppStatus.unauthenticated;
    await _saveStatus();
    await SharedPreferencesUtil.clearAppState();
    notifyListeners();
  }

  // --- Onboarding Flow ---
  Future<void> completeOnboarding() async {
    // After onboarding, maybe user has incomplete profile
    _status = AppStatus.profileIncomplete;
    await _saveStatus();
    notifyListeners();
  }

  // --- Profile Flow ---
  Future<void> completeProfile() async {
    _status = AppStatus.authenticated;
    await _saveStatus();
    notifyListeners();
  }

  // --- Utility ---
  Future<void> setUnknown() async {
    _status = AppStatus.unknown;
    await _saveStatus();
    notifyListeners();
  }

  /// Set authenticated status directly (for when user is already logged in)
  Future<void> setAuthenticated() async {
    _status = AppStatus.authenticated;
    await _saveStatus();
    notifyListeners();
  }
}
