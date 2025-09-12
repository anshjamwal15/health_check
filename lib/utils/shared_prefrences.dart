import 'package:health_check/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SharedPreferencesUtil {
  static final SharedPreferencesUtil _instance =
      SharedPreferencesUtil._internal();

  factory SharedPreferencesUtil() {
    return _instance;
  }

  SharedPreferencesUtil._internal();

  static Future<void> saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  static Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  /// Save User object as JSON
  static Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    String userJson = jsonEncode(user.toMap());
    await prefs.setString('user', userJson);
  }

  /// Get User object from JSON
  static Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson == null) return null;

    final Map<String, dynamic> map = jsonDecode(userJson);
    return User.fromMap(map);
  }

  static Future<void> deleteUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
  }

  static Future<void> updateUser(User newUser) async {
    final existingUser = await getUser();

    if (existingUser != null) {
      // Example: merging data (you can customize merge logic in User class)
      final updatedUser = existingUser.copyWith(
        name: newUser.name,
        email: newUser.email,
        photoUrl: newUser.photoUrl,
      );

      await saveUser(updatedUser);
    } else {
      // If no user exists, just save the new one
      await saveUser(newUser);
    }
  }

  /// Save App Status
  static Future<void> saveAppStatus(String status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_status', status);
  }

  /// Get App Status
  static Future<String?> getAppStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('app_status');
  }

  /// Save Bottom Navigation Index
  static Future<void> saveBottomNavIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('bottom_nav_index', index);
  }

  /// Get Bottom Navigation Index
  static Future<int> getBottomNavIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('bottom_nav_index') ?? 0;
  }

  /// Clear all app state data
  static Future<void> clearAppState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('app_status');
    await prefs.remove('bottom_nav_index');
    await prefs.remove('user');
  }
}
