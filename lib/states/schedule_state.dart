import 'package:flutter/foundation.dart';
import 'package:health_check/models/schedule.dart';
import 'package:health_check/repository/schedule_repository.dart';
import 'package:health_check/utils/shared_prefrences.dart';

class ScheduleState extends ChangeNotifier {
  final ScheduleRepository _repository = ScheduleRepository();
  
  List<Schedule> _schedules = [];
  List<Schedule> _filteredSchedules = [];
  bool _isLoading = false;
  String? _error;
  ScheduleType _selectedType = ScheduleType.day;
  DateTime _selectedDate = DateTime.now();

  // Getters
  List<Schedule> get schedules => _filteredSchedules;
  bool get isLoading => _isLoading;
  String? get error => _error;
  ScheduleType get selectedType => _selectedType;
  DateTime get selectedDate => _selectedDate;

  // Initialize schedule state from saved preferences
  Future<void> initializeFromStorage(String userId) async {
    _setLoading(true);
    try {
      final savedSchedules = await SharedPreferencesUtil.getSchedulesByUserId(userId);
      _schedules = savedSchedules;
      _filterSchedules();
      _error = null;
    } catch (e) {
      _error = 'Failed to load schedules: $e';
      debugPrint('Error loading schedules: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load schedules for a specific user
  Future<void> loadSchedules(String userId) async {
    _setLoading(true);
    try {
      final fetchedSchedules = await _repository.getSchedulesByUserId(userId);
      _schedules = fetchedSchedules;
      _filterSchedules();
      _error = null;
    } catch (e) {
      _error = 'Failed to load schedules: $e';
      debugPrint('Error loading schedules: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Add a new schedule
  Future<bool> addSchedule(Schedule schedule) async {
    _setLoading(true);
    try {
      await _repository.create(schedule);
      _schedules.add(schedule);
      _filterSchedules();
      _error = null;
      return true;
    } catch (e) {
      _error = 'Failed to add schedule: $e';
      debugPrint('Error adding schedule: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update an existing schedule
  Future<bool> updateSchedule(Schedule schedule) async {
    _setLoading(true);
    try {
      await _repository.update(schedule);
      final index = _schedules.indexWhere((s) => s.id == schedule.id);
      if (index != -1) {
        _schedules[index] = schedule;
        _filterSchedules();
      }
      _error = null;
      return true;
    } catch (e) {
      _error = 'Failed to update schedule: $e';
      debugPrint('Error updating schedule: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete a schedule
  Future<bool> deleteSchedule(String scheduleId) async {
    _setLoading(true);
    try {
      await _repository.delete(scheduleId);
      _schedules.removeWhere((s) => s.id == scheduleId);
      _filterSchedules();
      _error = null;
      return true;
    } catch (e) {
      _error = 'Failed to delete schedule: $e';
      debugPrint('Error deleting schedule: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Change schedule type filter
  void setScheduleType(ScheduleType type) {
    _selectedType = type;
    _filterSchedules();
  }

  // Change selected date
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    _filterSchedules();
  }

  // Filter schedules based on selected type and date
  void _filterSchedules() {
    final now = _selectedDate;
    
    switch (_selectedType) {
      case ScheduleType.day:
        final startOfDay = DateTime(now.year, now.month, now.day);
        final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
        _filteredSchedules = _schedules.where((schedule) {
          return schedule.startDateTime.isAfter(startOfDay.subtract(const Duration(microseconds: 1))) &&
                 schedule.startDateTime.isBefore(endOfDay.add(const Duration(microseconds: 1)));
        }).toList();
        break;
        
      case ScheduleType.week:
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
        _filteredSchedules = _schedules.where((schedule) {
          return schedule.startDateTime.isAfter(startOfWeek.subtract(const Duration(microseconds: 1))) &&
                 schedule.startDateTime.isBefore(endOfWeek.add(const Duration(microseconds: 1)));
        }).toList();
        break;
        
      case ScheduleType.month:
        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        _filteredSchedules = _schedules.where((schedule) {
          return schedule.startDateTime.isAfter(startOfMonth.subtract(const Duration(microseconds: 1))) &&
                 schedule.startDateTime.isBefore(endOfMonth.add(const Duration(microseconds: 1)));
        }).toList();
        break;
    }

    // Sort by start time
    _filteredSchedules.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
    notifyListeners();
  }

  // Get schedules for a specific date
  List<Schedule> getSchedulesForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    
    return _schedules.where((schedule) {
      return schedule.startDateTime.isAfter(startOfDay.subtract(const Duration(microseconds: 1))) &&
             schedule.startDateTime.isBefore(endOfDay.add(const Duration(microseconds: 1)));
    }).toList()
    ..sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
  }

  // Get upcoming schedules
  List<Schedule> getUpcomingSchedules({int limit = 5}) {
    final now = DateTime.now();
    final upcoming = _schedules.where((schedule) {
      return schedule.startDateTime.isAfter(now) && 
             schedule.status != ScheduleStatus.completed &&
             schedule.status != ScheduleStatus.cancelled;
    }).toList()
    ..sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
    
    return upcoming.take(limit).toList();
  }

  // Get overdue schedules
  List<Schedule> getOverdueSchedules() {
    final now = DateTime.now();
    return _schedules.where((schedule) {
      return schedule.endDateTime.isBefore(now) && 
             schedule.status == ScheduleStatus.pending;
    }).toList()
    ..sort((a, b) => a.endDateTime.compareTo(b.endDateTime));
  }

  // Mark schedule as completed
  Future<bool> markScheduleCompleted(String scheduleId) async {
    final schedule = _schedules.firstWhere((s) => s.id == scheduleId);
    final updatedSchedule = schedule.copyWith(status: ScheduleStatus.completed);
    return await updateSchedule(updatedSchedule);
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Private helper to set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Clear all schedules
  void clearSchedules() {
    _schedules.clear();
    _filteredSchedules.clear();
    notifyListeners();
  }
}