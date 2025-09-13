import 'package:flutter/material.dart';
import 'package:health_check/models/schedule.dart';
import 'package:health_check/repository/schedule_repository.dart';
import 'package:health_check/utils/app_utils.dart';

class ScheduleService {
  final ScheduleRepository _repository = ScheduleRepository();

  /// Create a new schedule
  Future<bool> createSchedule(BuildContext context, Schedule schedule) async {
    try {
      await _repository.create(schedule);
      AppUtils.showSnackBar(context, 'Schedule created successfully!', backgroundColor: Colors.green);
      return true;
    } catch (e) {
      AppUtils.showSnackBar(context, 'Failed to create schedule: $e', backgroundColor: Colors.red);
      debugPrint('Error creating schedule: $e');
      return false;
    }
  }

  /// Update an existing schedule
  Future<bool> updateSchedule(BuildContext context, Schedule schedule) async {
    try {
      await _repository.update(schedule);
      AppUtils.showSnackBar(context, 'Schedule updated successfully!', backgroundColor: Colors.green);
      return true;
    } catch (e) {
      AppUtils.showSnackBar(context, 'Failed to update schedule: $e', backgroundColor: Colors.red);
      debugPrint('Error updating schedule: $e');
      return false;
    }
  }

  /// Delete a schedule
  Future<bool> deleteSchedule(BuildContext context, String scheduleId) async {
    try {
      await _repository.delete(scheduleId);
      AppUtils.showSnackBar(context, 'Schedule deleted successfully!', backgroundColor: Colors.orange);
      return true;
    } catch (e) {
      AppUtils.showSnackBar(context, 'Failed to delete schedule: $e', backgroundColor: Colors.red);
      debugPrint('Error deleting schedule: $e');
      return false;
    }
  }

  /// Get all schedules for a user
  Future<List<Schedule>> getUserSchedules(String userId) async {
    try {
      return await _repository.getSchedulesByUserId(userId);
    } catch (e) {
      debugPrint('Error getting user schedules: $e');
      return [];
    }
  }

  /// Get today's schedules
  Future<List<Schedule>> getTodaySchedules(String userId) async {
    try {
      return await _repository.getTodaySchedules(userId);
    } catch (e) {
      debugPrint('Error getting today schedules: $e');
      return [];
    }
  }

  /// Get this week's schedules
  Future<List<Schedule>> getWeekSchedules(String userId) async {
    try {
      return await _repository.getWeekSchedules(userId);
    } catch (e) {
      debugPrint('Error getting week schedules: $e');
      return [];
    }
  }

  /// Get this month's schedules
  Future<List<Schedule>> getMonthSchedules(String userId) async {
    try {
      return await _repository.getMonthSchedules(userId);
    } catch (e) {
      debugPrint('Error getting month schedules: $e');
      return [];
    }
  }

  /// Get schedules by date range
  Future<List<Schedule>> getSchedulesByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      return await _repository.getSchedulesByDateRange(userId, startDate, endDate);
    } catch (e) {
      debugPrint('Error getting schedules by date range: $e');
      return [];
    }
  }

  /// Mark schedule as completed
  Future<bool> markScheduleCompleted(BuildContext context, Schedule schedule) async {
    final completedSchedule = schedule.copyWith(status: ScheduleStatus.completed);
    return await updateSchedule(context, completedSchedule);
  }

  /// Mark schedule as in progress
  Future<bool> markScheduleInProgress(BuildContext context, Schedule schedule) async {
    final inProgressSchedule = schedule.copyWith(status: ScheduleStatus.inProgress);
    return await updateSchedule(context, inProgressSchedule);
  }

  /// Mark schedule as cancelled
  Future<bool> markScheduleCancelled(BuildContext context, Schedule schedule) async {
    final cancelledSchedule = schedule.copyWith(status: ScheduleStatus.cancelled);
    return await updateSchedule(context, cancelledSchedule);
  }

  /// Get upcoming schedules (next 7 days)
  Future<List<Schedule>> getUpcomingSchedules(String userId, {int days = 7}) async {
    try {
      final now = DateTime.now();
      final futureDate = now.add(Duration(days: days));
      final schedules = await _repository.getSchedulesByDateRange(userId, now, futureDate);
      
      return schedules.where((schedule) {
        return schedule.startDateTime.isAfter(now) &&
               schedule.status != ScheduleStatus.completed &&
               schedule.status != ScheduleStatus.cancelled;
      }).toList()
      ..sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
    } catch (e) {
      debugPrint('Error getting upcoming schedules: $e');
      return [];
    }
  }

  /// Get overdue schedules
  Future<List<Schedule>> getOverdueSchedules(String userId) async {
    try {
      final now = DateTime.now();
      final allSchedules = await _repository.getSchedulesByUserId(userId);
      
      return allSchedules.where((schedule) {
        return schedule.endDateTime.isBefore(now) &&
               schedule.status == ScheduleStatus.pending;
      }).toList()
      ..sort((a, b) => a.endDateTime.compareTo(b.endDateTime));
    } catch (e) {
      debugPrint('Error getting overdue schedules: $e');
      return [];
    }
  }

  /// Get schedules by priority
  Future<List<Schedule>> getSchedulesByPriority(String userId, SchedulePriority priority) async {
    try {
      final allSchedules = await _repository.getSchedulesByUserId(userId);
      return allSchedules.where((schedule) => schedule.priority == priority).toList()
        ..sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
    } catch (e) {
      debugPrint('Error getting schedules by priority: $e');
      return [];
    }
  }

  /// Get schedules by status
  Future<List<Schedule>> getSchedulesByStatus(String userId, ScheduleStatus status) async {
    try {
      final allSchedules = await _repository.getSchedulesByUserId(userId);
      return allSchedules.where((schedule) => schedule.status == status).toList()
        ..sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
    } catch (e) {
      debugPrint('Error getting schedules by status: $e');
      return [];
    }
  }

  /// Search schedules by title or description
  Future<List<Schedule>> searchSchedules(String userId, String query) async {
    try {
      final allSchedules = await _repository.getSchedulesByUserId(userId);
      final lowerQuery = query.toLowerCase();
      
      return allSchedules.where((schedule) {
        return schedule.title.toLowerCase().contains(lowerQuery) ||
               schedule.description.toLowerCase().contains(lowerQuery) ||
               (schedule.location?.toLowerCase().contains(lowerQuery) ?? false) ||
               schedule.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
      }).toList()
      ..sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
    } catch (e) {
      debugPrint('Error searching schedules: $e');
      return [];
    }
  }

  /// Get statistics for user schedules
  Future<Map<String, dynamic>> getScheduleStatistics(String userId) async {
    try {
      final allSchedules = await _repository.getSchedulesByUserId(userId);
      final now = DateTime.now();
      
      final total = allSchedules.length;
      final completed = allSchedules.where((s) => s.status == ScheduleStatus.completed).length;
      final pending = allSchedules.where((s) => s.status == ScheduleStatus.pending).length;
      final inProgress = allSchedules.where((s) => s.status == ScheduleStatus.inProgress).length;
      final cancelled = allSchedules.where((s) => s.status == ScheduleStatus.cancelled).length;
      
      final overdue = allSchedules.where((s) => 
        s.endDateTime.isBefore(now) && s.status == ScheduleStatus.pending
      ).length;
      
      final upcoming = allSchedules.where((s) => 
        s.startDateTime.isAfter(now) && 
        s.status != ScheduleStatus.completed && 
        s.status != ScheduleStatus.cancelled
      ).length;

      final todaySchedules = allSchedules.where((s) {
        final today = DateTime.now();
        final scheduleDate = s.startDateTime;
        return scheduleDate.year == today.year &&
               scheduleDate.month == today.month &&
               scheduleDate.day == today.day;
      }).length;

      final thisWeekSchedules = allSchedules.where((s) {
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 6));
        return s.startDateTime.isAfter(weekStart.subtract(const Duration(days: 1))) &&
               s.startDateTime.isBefore(weekEnd.add(const Duration(days: 1)));
      }).length;

      return {
        'total': total,
        'completed': completed,
        'pending': pending,
        'inProgress': inProgress,
        'cancelled': cancelled,
        'overdue': overdue,
        'upcoming': upcoming,
        'today': todaySchedules,
        'thisWeek': thisWeekSchedules,
        'completionRate': total > 0 ? (completed / total * 100).round() : 0,
      };
    } catch (e) {
      debugPrint('Error getting schedule statistics: $e');
      return {
        'total': 0,
        'completed': 0,
        'pending': 0,
        'inProgress': 0,
        'cancelled': 0,
        'overdue': 0,
        'upcoming': 0,
        'today': 0,
        'thisWeek': 0,
        'completionRate': 0,
      };
    }
  }

  /// Duplicate a schedule
  Future<bool> duplicateSchedule(BuildContext context, Schedule originalSchedule, DateTime newDate) async {
    try {
      final newSchedule = originalSchedule.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        startDateTime: DateTime(
          newDate.year,
          newDate.month,
          newDate.day,
          originalSchedule.startDateTime.hour,
          originalSchedule.startDateTime.minute,
        ),
        endDateTime: DateTime(
          newDate.year,
          newDate.month,
          newDate.day,
          originalSchedule.endDateTime.hour,
          originalSchedule.endDateTime.minute,
        ),
        status: ScheduleStatus.pending,
      );

      await _repository.create(newSchedule);
      AppUtils.showSnackBar(context, 'Schedule duplicated successfully!', backgroundColor: Colors.green);
      return true;
    } catch (e) {
      AppUtils.showSnackBar(context, 'Failed to duplicate schedule: $e', backgroundColor: Colors.red);
      debugPrint('Error duplicating schedule: $e');
      return false;
    }
  }

  /// Bulk update schedules status
  Future<bool> bulkUpdateStatus(
    BuildContext context,
    List<String> scheduleIds,
    ScheduleStatus newStatus,
  ) async {
    try {
      int successCount = 0;
      for (final id in scheduleIds) {
        final schedule = await _repository.read(id);
        if (schedule != null) {
          final updatedSchedule = schedule.copyWith(status: newStatus);
          await _repository.update(updatedSchedule);
          successCount++;
        }
      }

      AppUtils.showSnackBar(
        context,
        'Updated $successCount schedule(s) successfully!',
        backgroundColor: Colors.green,
      );
      return true;
    } catch (e) {
      AppUtils.showSnackBar(context, 'Failed to bulk update schedules: $e', backgroundColor: Colors.red);
      debugPrint('Error bulk updating schedules: $e');
      return false;
    }
  }

  /// Check for schedule conflicts
  Future<List<Schedule>> checkScheduleConflicts(String userId, Schedule newSchedule) async {
    try {
      final existingSchedules = await _repository.getSchedulesByDateRange(
        userId,
        newSchedule.startDateTime.subtract(const Duration(days: 1)),
        newSchedule.endDateTime.add(const Duration(days: 1)),
      );

      return existingSchedules.where((existing) {
        // Skip the same schedule if updating
        if (existing.id == newSchedule.id) return false;
        
        // Check for time overlap
        return (newSchedule.startDateTime.isBefore(existing.endDateTime) &&
                newSchedule.endDateTime.isAfter(existing.startDateTime));
      }).toList();
    } catch (e) {
      debugPrint('Error checking schedule conflicts: $e');
      return [];
    }
  }

  /// Get schedule reminders (schedules starting within next hour)
  Future<List<Schedule>> getScheduleReminders(String userId) async {
    try {
      final now = DateTime.now();
      final nextHour = now.add(const Duration(hours: 1));
      
      final schedules = await _repository.getSchedulesByDateRange(userId, now, nextHour);
      
      return schedules.where((schedule) {
        return schedule.status == ScheduleStatus.pending &&
               schedule.startDateTime.isAfter(now) &&
               schedule.startDateTime.isBefore(nextHour);
      }).toList()
      ..sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
    } catch (e) {
      debugPrint('Error getting schedule reminders: $e');
      return [];
    }
  }

  /// Export schedules to a simple text format
  String exportSchedulesToText(List<Schedule> schedules) {
    final buffer = StringBuffer();
    buffer.writeln('My Schedules Export');
    buffer.writeln('==================');
    buffer.writeln('Generated on: ${DateTime.now().toString()}');
    buffer.writeln();

    for (final schedule in schedules) {
      buffer.writeln('Title: ${schedule.title}');
      buffer.writeln('Description: ${schedule.description}');
      buffer.writeln('Date: ${schedule.formattedDate}');
      buffer.writeln('Time: ${schedule.formattedStartTime} - ${schedule.formattedEndTime}');
      buffer.writeln('Status: ${schedule.status.name.toUpperCase()}');
      buffer.writeln('Priority: ${schedule.priority.name.toUpperCase()}');
      if (schedule.location != null) {
        buffer.writeln('Location: ${schedule.location}');
      }
      if (schedule.tags.isNotEmpty) {
        buffer.writeln('Tags: ${schedule.tags.join(', ')}');
      }
      buffer.writeln('---');
    }

    return buffer.toString();
  }
}