import 'package:hive/hive.dart';

part 'schedule_model.g.dart';

/// Hive type ID for ScheduleModel
@HiveType(typeId: 3)
class ScheduleModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String subjectId;

  @HiveField(2)
  String topicId;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  String time; // stored as "HH:mm"

  @HiveField(5)
  double durationHours; // in hours

  @HiveField(6)
  bool completed;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  bool isSynced;

  @HiveField(9)
  String? notes;

  ScheduleModel({
    required this.id,
    required this.subjectId,
    required this.topicId,
    required this.date,
    required this.time,
    required this.durationHours,
    this.completed = false,
    required this.createdAt,
    this.isSynced = false,
    this.notes,
  });

  /// Full DateTime combining date and time string
  DateTime get scheduledDateTime {
    final parts = time.split(':');
    return DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  /// Check if this session is overdue (not completed and past now)
  bool get isOverdue =>
      !completed && scheduledDateTime.isBefore(DateTime.now());

  /// Returns a copy with updated fields
  ScheduleModel copyWith({
    String? id,
    String? subjectId,
    String? topicId,
    DateTime? date,
    String? time,
    double? durationHours,
    bool? completed,
    DateTime? createdAt,
    bool? isSynced,
    String? notes,
  }) {
    return ScheduleModel(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      topicId: topicId ?? this.topicId,
      date: date ?? this.date,
      time: time ?? this.time,
      durationHours: durationHours ?? this.durationHours,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
      notes: notes ?? this.notes,
    );
  }

  /// Convert to Map for export/import
  Map<String, dynamic> toMap() => {
        'id': id,
        'subjectId': subjectId,
        'topicId': topicId,
        'date': date.toIso8601String(),
        'time': time,
        'durationHours': durationHours,
        'completed': completed,
        'createdAt': createdAt.toIso8601String(),
        'isSynced': isSynced,
        'notes': notes,
      };

  factory ScheduleModel.fromMap(Map<String, dynamic> map) => ScheduleModel(
        id: map['id'],
        subjectId: map['subjectId'],
        topicId: map['topicId'],
        date: DateTime.parse(map['date']),
        time: map['time'],
        durationHours: (map['durationHours'] as num).toDouble(),
        completed: map['completed'] ?? false,
        createdAt: DateTime.parse(map['createdAt']),
        isSynced: map['isSynced'] ?? false,
        notes: map['notes'],
      );
}
