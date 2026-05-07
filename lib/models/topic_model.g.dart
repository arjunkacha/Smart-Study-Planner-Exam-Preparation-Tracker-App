// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topic_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TopicStatusAdapter extends TypeAdapter<TopicStatus> {
  @override
  final int typeId = 1;

  @override
  TopicStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TopicStatus.notStarted;
      case 1:
        return TopicStatus.inProgress;
      case 2:
        return TopicStatus.completed;
      default:
        return TopicStatus.notStarted;
    }
  }

  @override
  void write(BinaryWriter writer, TopicStatus obj) {
    switch (obj) {
      case TopicStatus.notStarted:
        writer.writeByte(0);
        break;
      case TopicStatus.inProgress:
        writer.writeByte(1);
        break;
      case TopicStatus.completed:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TopicStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TopicModelAdapter extends TypeAdapter<TopicModel> {
  @override
  final int typeId = 2;

  @override
  TopicModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TopicModel(
      id: fields[0] as String,
      subjectId: fields[1] as String,
      name: fields[2] as String,
      estimatedTimeHours: fields[3] as double,
      status: fields[4] as TopicStatus,
      lastStudied: fields[5] as DateTime?,
      createdAt: fields[6] as DateTime,
      isSynced: fields[7] as bool,
      notes: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TopicModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.subjectId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.estimatedTimeHours)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.lastStudied)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.isSynced)
      ..writeByte(8)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TopicModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
