import 'package:health_check/models/schedule.dart';
import 'package:health_check/repository/base_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health_check/utils/shared_prefrences.dart';

class ScheduleRepository implements BaseRepository<Schedule> {
  final CollectionReference _schedulesRef = 
      FirebaseFirestore.instance.collection('schedules');

  @override
  Future<void> create(Schedule schedule) async {
    schedule.touch();
    await _schedulesRef.doc(schedule.id).set(schedule.toMap());
    await SharedPreferencesUtil.saveSchedule(schedule);
  }

  @override
  Future<Schedule?> read(String id) async {
    final cachedSchedule = await SharedPreferencesUtil.getSchedule(id);
    if (cachedSchedule != null) return cachedSchedule;

    final doc = await _schedulesRef.doc(id).get();
    if (!doc.exists) return null;
    return Schedule.fromMap(doc.data() as Map<String, dynamic>);
  }

  @override
  Future<void> update(Schedule schedule) async {
    schedule.touch();
    await _schedulesRef.doc(schedule.id).update(schedule.toMap());
    await SharedPreferencesUtil.updateSchedule(schedule);
  }

  @override
  Future<void> delete(String id) async {
    final doc = await _schedulesRef.doc(id).get();
    if (!doc.exists) return;

    final schedule = Schedule.fromMap(doc.data() as Map<String, dynamic>);
    schedule.markDeleted();
    await _schedulesRef.doc(id).update(schedule.toMap());
    await SharedPreferencesUtil.deleteSchedule(id);
  }

  @override
  Future<List<Schedule>> getAll() async {
    final snapshot = await _schedulesRef.get();
    return snapshot.docs
        .map((doc) => Schedule.fromMap(doc.data() as Map<String, dynamic>))
        .where((schedule) => schedule.deletedAt == null) // Filter in client
        .toList();
  }

  // Simplified: Get schedules by user ID (single field query - no index needed)
  Future<List<Schedule>> getSchedulesByUserId(String userId) async {
    // Try to get from cache first
    final cachedSchedules = await SharedPreferencesUtil.getAllSchedules();
    final userCachedSchedules = cachedSchedules
        .where((schedule) => schedule.userId == userId && schedule.deletedAt == null)
        .toList();
    
    if (userCachedSchedules.isNotEmpty) {
      return userCachedSchedules;
    }

    // Simple query - only filter by user_id (no composite index needed)
    final snapshot = await _schedulesRef
        .where('user_id', isEqualTo: userId)
        .get();
    
    final schedules = snapshot.docs
        .map((doc) => Schedule.fromMap(doc.data() as Map<String, dynamic>))
        .where((schedule) => schedule.deletedAt == null) // Filter deleted in client
        .toList();
    
    // Sort in client instead of database
    schedules.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
    
    // Cache the results
    for (final schedule in schedules) {
      await SharedPreferencesUtil.saveSchedule(schedule);
    }
    
    return schedules;
  }

  // Client-side filtering for date ranges (no complex indexes needed)
  Future<List<Schedule>> getSchedulesByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    // Get all user schedules first
    final allSchedules = await getSchedulesByUserId(userId);
    
    // Filter by date range in client
    return allSchedules.where((schedule) {
      return schedule.startDateTime.isAfter(startDate.subtract(const Duration(days: 1))) &&
             schedule.startDateTime.isBefore(endDate.add(const Duration(days: 1))) &&
             schedule.deletedAt == null;
    }).toList()
    ..sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
  }

  // Get schedules by type (client-side filtering)
  Future<List<Schedule>> getSchedulesByType(
    String userId,
    ScheduleType type,
  ) async {
    final allSchedules = await getSchedulesByUserId(userId);
    return allSchedules.where((schedule) => schedule.type == type).toList()
      ..sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
  }

  // Get today's schedules
  Future<List<Schedule>> getTodaySchedules(String userId) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);
    
    return getSchedulesByDateRange(userId, startOfDay, endOfDay);
  }

  // Get this week's schedules
  Future<List<Schedule>> getWeekSchedules(String userId) async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    return getSchedulesByDateRange(userId, startOfWeek, endOfWeek);
  }

  // Get this month's schedules
  Future<List<Schedule>> getMonthSchedules(String userId) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    
    return getSchedulesByDateRange(userId, startOfMonth, endOfMonth);
  }
}