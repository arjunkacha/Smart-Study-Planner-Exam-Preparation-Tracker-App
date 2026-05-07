// ignore_for_file: invalid_annotation_target
import 'package:hive/hive.dart';

part 'subject_model.g.dart';

/// Hive type ID for SubjectModel
@HiveType(typeId: 0)
class SubjectModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int colorValue; // stored as int (Color.value)

  @HiveField(3)
  String iconName; // icon identifier string

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  bool isSynced;

  SubjectModel({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.iconName,
    required this.createdAt,
    this.isSynced = false,
  });

  /// Returns a copy of this model with updated fields
  SubjectModel copyWith({
    String? id,
    String? name,
    int? colorValue,
    String? iconName,
    DateTime? createdAt,
    bool? isSynced,
  }) {
    return SubjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      iconName: iconName ?? this.iconName,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  /// Convert to Map for export/import
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'colorValue': colorValue,
        'iconName': iconName,
        'createdAt': createdAt.toIso8601String(),
        'isSynced': isSynced,
      };

  factory SubjectModel.fromMap(Map<String, dynamic> map) => SubjectModel(
        id: map['id'],
        name: map['name'],
        colorValue: map['colorValue'],
        iconName: map['iconName'],
        createdAt: DateTime.parse(map['createdAt']),
        isSynced: map['isSynced'] ?? false,
      );
}
