import 'package:hive/hive.dart';

part 'topic_model.g.dart';

/// Topic status enumeration
@HiveType(typeId: 1)
enum TopicStatus {
  @HiveField(0)
  notStarted,

  @HiveField(1)
  inProgress,

  @HiveField(2)
  completed,
}

/// Extension to provide display names for TopicStatus
extension TopicStatusExtension on TopicStatus {
  String get displayName {
    switch (this) {
      case TopicStatus.notStarted:
        return 'Not Started';
      case TopicStatus.inProgress:
        return 'In Progress';
      case TopicStatus.completed:
        return 'Completed';
    }
  }
}

/// Hive type ID for TopicModel
@HiveType(typeId: 2)
class TopicModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String subjectId;

  @HiveField(2)
  String name;

  @HiveField(3)
  double estimatedTimeHours; // in hours

  @HiveField(4)
  TopicStatus status;

  @HiveField(5)
  DateTime? lastStudied;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  bool isSynced;

  @HiveField(8)
  String? notes;

  TopicModel({
    required this.id,
    required this.subjectId,
    required this.name,
    required this.estimatedTimeHours,
    this.status = TopicStatus.notStarted,
    this.lastStudied,
    required this.createdAt,
    this.isSynced = false,
    this.notes,
  });

  /// Returns a copy with updated fields
  TopicModel copyWith({
    String? id,
    String? subjectId,
    String? name,
    double? estimatedTimeHours,
    TopicStatus? status,
    DateTime? lastStudied,
    DateTime? createdAt,
    bool? isSynced,
    String? notes,
  }) {
    return TopicModel(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      name: name ?? this.name,
      estimatedTimeHours: estimatedTimeHours ?? this.estimatedTimeHours,
      status: status ?? this.status,
      lastStudied: lastStudied ?? this.lastStudied,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
      notes: notes ?? this.notes,
    );
  }

  /// Convert to Map for export/import
  Map<String, dynamic> toMap() => {
        'id': id,
        'subjectId': subjectId,
        'name': name,
        'estimatedTimeHours': estimatedTimeHours,
        'status': status.index,
        'lastStudied': lastStudied?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'isSynced': isSynced,
        'notes': notes,
      };

  factory TopicModel.fromMap(Map<String, dynamic> map) => TopicModel(
        id: map['id'],
        subjectId: map['subjectId'],
        name: map['name'],
        estimatedTimeHours: (map['estimatedTimeHours'] as num).toDouble(),
        status: TopicStatus.values[map['status']],
        lastStudied: map['lastStudied'] != null
            ? DateTime.parse(map['lastStudied'])
            : null,
        createdAt: DateTime.parse(map['createdAt']),
        isSynced: map['isSynced'] ?? false,
        notes: map['notes'],
      );
}
