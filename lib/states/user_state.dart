import 'package:flutter/foundation.dart';
import 'package:health_check/models/user.dart';
import 'package:health_check/repository/user_repository.dart';

class UserState extends ChangeNotifier {
  User? _user;
  final UserRepository _repository = UserRepository();

  User? get user => _user;

  /// Set and persist user
  Future<void> setUser(User user) async {
    _user = user;
    notifyListeners();

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

    await _repository.update(user);
  }

  /// Soft delete user
  Future<void> clearUser() async {
    if (_user != null) {
      await _repository.delete(_user!.id);
    }
    _user = null;
    notifyListeners();
  }

  /// Get all users
  Future<List<User>> getAllUsers() async {
    return await _repository.getAll();
  }
}
