import 'package:flutter/foundation.dart';
import 'package:health_check/models/user.dart';
import 'package:health_check/repository/user_repository.dart';
import 'package:health_check/utils/shared_prefrences.dart';
import 'package:health_check/states/app_state.dart';

class UserState extends ChangeNotifier {
  User? _user;
  final UserRepository _repository = UserRepository();

  User? get user => _user;

  /// Initialize user state from saved preferences
  Future<void> initializeFromStorage() async {
    final savedUser = await SharedPreferencesUtil.getUser();
    if (savedUser != null) {
      _user = savedUser;
      notifyListeners();
    }
  }

  /// Update app status for current user and sync to Firebase
  Future<void> updateAppStatus(AppStatus newStatus) async {
    if (_user != null) {
      final updatedUser = _user!.copyWith(appStatus: newStatus);
      _user = updatedUser;
      
      // Save to SharedPreferences
      await SharedPreferencesUtil.saveUser(updatedUser);
      
      // Save to Firebase
      await _repository.update(updatedUser);
      
      notifyListeners();
    }
  }

  /// Set and persist user
  Future<void> setUser(User user) async {
    _user = user;
    notifyListeners();

    // Save to SharedPreferences
    await SharedPreferencesUtil.saveUser(user);
    
    // Save to Firestore
    await _repository.create(user);
  }

  /// Load user by ID from Firestore
  Future<void> loadUser(String id) async {
    final fetchedUser = await _repository.read(id);
    if (fetchedUser != null) {
      _user = fetchedUser;
      notifyListeners();
    }
  }

  /// Update user info
  Future<void> updateUser(User user) async {
    _user = user;
    notifyListeners();

    // Update in SharedPreferences
    await SharedPreferencesUtil.updateUser(user);
    
    await _repository.update(user);
  }

  /// Soft delete user
  Future<void> clearUser() async {
    if (_user != null) {
      await _repository.delete(_user!.id);
    }
    _user = null;
    
    // Clear from SharedPreferences
    await SharedPreferencesUtil.deleteUser();
    
    notifyListeners();
  }

  /// Get all users
  Future<List<User>> getAllUsers() async {
    return await _repository.getAll();
  }
}
