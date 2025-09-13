
import 'package:health_check/models/user.dart';
import 'package:health_check/models/schedule.dart';
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

  // ========== USER METHODS ==========
  
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
      final updatedUser = existingUser.copyWith(
        name: newUser.name,
        email: newUser.email,
        photoUrl: newUser.photoUrl,
      );
      await saveUser(updatedUser);
    } else {
      await saveUser(newUser);
    }
  }

  // ========== SCHEDULE METHODS ==========
  
  /// Save Schedule object as JSON
  static Future<void> saveSchedule(Schedule schedule) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get existing schedules
    final existingSchedules = await getAllSchedules();
    
    // Remove any existing schedule with same ID
    existingSchedules.removeWhere((s) => s.id == schedule.id);
    
    // Add the new/updated schedule
    existingSchedules.add(schedule);
    
    // Convert to JSON and save
    final schedulesList = existingSchedules.map((s) => s.toMap()).toList();
    final schedulesJson = jsonEncode(schedulesList);
    await prefs.setString('schedules', schedulesJson);
  }

  /// Get specific Schedule by ID
  static Future<Schedule?> getSchedule(String id) async {
    final allSchedules = await getAllSchedules();
    try {
      return allSchedules.firstWhere((schedule) => schedule.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get all Schedules
  static Future<List<Schedule>> getAllSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final schedulesJson = prefs.getString('schedules');
    if (schedulesJson == null) return [];

    final List<dynamic> schedulesList = jsonDecode(schedulesJson);
    return schedulesList
        .map((map) => Schedule.fromMap(Map<String, dynamic>.from(map)))
        .where((schedule) => schedule.deletedAt == null) // Filter out deleted schedules
        .toList();
  }

  /// Update existing Schedule
  static Future<void> updateSchedule(Schedule updatedSchedule) async {
    await saveSchedule(updatedSchedule); // saveSchedule already handles updates
  }

  /// Delete Schedule by ID
  static Future<void> deleteSchedule(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final allSchedules = await getAllSchedules();
    
    // Mark as deleted instead of removing
    final scheduleIndex = allSchedules.indexWhere((s) => s.id == id);
    if (scheduleIndex != -1) {
      allSchedules[scheduleIndex].markDeleted();
      
      // Save updated list including the deleted schedule
      final schedulesList = allSchedules.map((s) => s.toMap()).toList();
      final schedulesJson = jsonEncode(schedulesList);
      await prefs.setString('schedules', schedulesJson);
    }
  }

  /// Get Schedules by User ID
  static Future<List<Schedule>> getSchedulesByUserId(String userId) async {
    final allSchedules = await getAllSchedules();
    return allSchedules.where((schedule) => schedule.userId == userId).toList();
  }

  /// Get Schedules by date range
  static Future<List<Schedule>> getSchedulesByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final userSchedules = await getSchedulesByUserId(userId);
    return userSchedules.where((schedule) {
      return schedule.startDateTime.isAfter(startDate.subtract(const Duration(days: 1))) &&
             schedule.startDateTime.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  /// Clear all schedules
  static Future<void> clearAllSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('schedules');
  }

  // ========== APP STATE METHODS ==========
  
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
    await prefs.remove('schedules');
  }
}