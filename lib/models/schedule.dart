import 'package:health_check/models/base_model.dart';

enum ScheduleType { day, week, month }
enum SchedulePriority { low, medium, high, urgent }
enum ScheduleStatus { pending, inProgress, completed, cancelled }

class Schedule extends BaseModel {
  final String id;
  String title;
  String description;
  DateTime startDateTime;
  DateTime endDateTime;
  ScheduleType type;
  SchedulePriority priority;
  ScheduleStatus status;
  String userId;
  String? location;
  List<String> tags;
  bool isRecurring;
  String? recurringPattern; // daily, weekly, monthly
  String? reminderTime; // e.g., "15 minutes before"

  Schedule({
    required this.id,
    required this.title,
    required this.description,
    required this.startDateTime,
    required this.endDateTime,
    required this.type,
    required this.userId,
    this.priority = SchedulePriority.medium,
    this.status = ScheduleStatus.pending,
    this.location,
    this.tags = const [],
    this.isRecurring = false,
    this.recurringPattern,
    this.reminderTime,
    super.createdAt,
    super.updatedAt,
    super.deletedAt,
  });

  // Getters for duration and formatted times
  Duration get duration => endDateTime.difference(startDateTime);
  
  String get formattedStartTime => 
    '${startDateTime.hour.toString().padLeft(2, '0')}:${startDateTime.minute.toString().padLeft(2, '0')}';
  
  String get formattedEndTime => 
    '${endDateTime.hour.toString().padLeft(2, '0')}:${endDateTime.minute.toString().padLeft(2, '0')}';

  String get formattedDate => 
    '${startDateTime.day}/${startDateTime.month}/${startDateTime.year}';

  // Setters that auto-update `updatedAt`
  set updateTitle(String newTitle) {
    title = newTitle;
    touch();
  }

  set updateDescription(String newDescription) {
    description = newDescription;
    touch();
  }

  set updateStatus(ScheduleStatus newStatus) {
    status = newStatus;
    touch();
  }

  set updatePriority(SchedulePriority newPriority) {
    priority = newPriority;
    touch();
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'start_date_time': startDateTime.toIso8601String(),
      'end_date_time': endDateTime.toIso8601String(),
      'type': type.name,
      'priority': priority.name,
      'status': status.name,
      'user_id': userId,
      'location': location,
      'tags': tags,
      'is_recurring': isRecurring,
      'recurring_pattern': recurringPattern,
      'reminder_time': reminderTime,
      ...super.toMap(),
    };
  }

  factory Schedule.fromMap(Map<String, dynamic> map) {
    return Schedule(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      startDateTime: DateTime.parse(map['start_date_time']),
      endDateTime: DateTime.parse(map['end_date_time']),
      type: _mapToScheduleType(map['type']),
      priority: _mapToSchedulePriority(map['priority']),
      status: _mapToScheduleStatus(map['status']),
      userId: map['user_id'] ?? '',
      location: map['location'],
      tags: List<String>.from(map['tags'] ?? []),
      isRecurring: map['is_recurring'] ?? false,
      recurringPattern: map['recurring_pattern'],
      reminderTime: map['reminder_time'],
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
      deletedAt: map['deleted_at'] != null
          ? DateTime.parse(map['deleted_at'])
          : null,
    );
  }

  // Helper methods to safely map strings to enums
  static ScheduleType _mapToScheduleType(dynamic value) {
    if (value == null) return ScheduleType.day;
    return ScheduleType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ScheduleType.day,
    );
  }

  static SchedulePriority _mapToSchedulePriority(dynamic value) {
    if (value == null) return SchedulePriority.medium;
    return SchedulePriority.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SchedulePriority.medium,
    );
  }

  static ScheduleStatus _mapToScheduleStatus(dynamic value) {
    if (value == null) return ScheduleStatus.pending;
    return ScheduleStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ScheduleStatus.pending,
    );
  }

  Schedule copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startDateTime,
    DateTime? endDateTime,
    ScheduleType? type,
    SchedulePriority? priority,
    ScheduleStatus? status,
    String? userId,
    String? location,
    List<String>? tags,
    bool? isRecurring,
    String? recurringPattern,
    String? reminderTime,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Schedule(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDateTime: startDateTime ?? this.startDateTime,
      endDateTime: endDateTime ?? this.endDateTime,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      location: location ?? this.location,
      tags: tags ?? this.tags,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringPattern: recurringPattern ?? this.recurringPattern,
      reminderTime: reminderTime ?? this.reminderTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}