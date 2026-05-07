import '../database/database_service.dart';
import '../models/subject_model.dart';
import '../models/topic_model.dart';
import '../models/schedule_model.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Seeds the app with sample data for demonstration purposes.
/// Only seeds if no subjects exist yet.
Future<void> seedSampleData(DatabaseService db) async {
  if (db.getAllSubjects().isNotEmpty) return;

  final now = DateTime.now();

  // === SUBJECTS ===
  final mathId = _uuid.v4();
  final physicsId = _uuid.v4();
  final historyId = _uuid.v4();

  await db.addSubject(SubjectModel(
    id: mathId,
    name: 'Mathematics',
    colorValue: 0xFF6C63FF, // purple
    iconName: 'math',
    createdAt: now.subtract(const Duration(days: 10)),
  ));
  await db.addSubject(SubjectModel(
    id: physicsId,
    name: 'Physics',
    colorValue: 0xFF3B82F6, // blue
    iconName: 'science',
    createdAt: now.subtract(const Duration(days: 8)),
  ));
  await db.addSubject(SubjectModel(
    id: historyId,
    name: 'History',
    colorValue: 0xFFF59E0B, // amber
    iconName: 'history',
    createdAt: now.subtract(const Duration(days: 5)),
  ));

  // === MATH TOPICS ===
  final mathTopics = [
    ('Algebra Basics', 2.0, TopicStatus.completed),
    ('Quadratic Equations', 1.5, TopicStatus.completed),
    ('Trigonometry', 3.0, TopicStatus.inProgress),
    ('Calculus - Limits', 2.5, TopicStatus.notStarted),
    ('Calculus - Derivatives', 3.0, TopicStatus.notStarted),
    ('Integration', 3.5, TopicStatus.notStarted),
    ('Probability & Statistics', 2.0, TopicStatus.notStarted),
  ];
  for (final (name, hours, status) in mathTopics) {
    await db.addTopic(TopicModel(
      id: _uuid.v4(),
      subjectId: mathId,
      name: name,
      estimatedTimeHours: hours,
      status: status,
      lastStudied: status != TopicStatus.notStarted
          ? now.subtract(Duration(days: status == TopicStatus.completed ? 3 : 1))
          : null,
      createdAt: now.subtract(const Duration(days: 9)),
    ));
  }

  // === PHYSICS TOPICS ===
  final physicsTopics = [
    ('Newton\'s Laws of Motion', 2.0, TopicStatus.completed),
    ('Kinematics', 1.5, TopicStatus.completed),
    ('Work, Energy & Power', 2.5, TopicStatus.inProgress),
    ('Electrostatics', 3.0, TopicStatus.notStarted),
    ('Electromagnetism', 3.5, TopicStatus.notStarted),
    ('Optics', 2.0, TopicStatus.notStarted),
  ];
  for (final (name, hours, status) in physicsTopics) {
    await db.addTopic(TopicModel(
      id: _uuid.v4(),
      subjectId: physicsId,
      name: name,
      estimatedTimeHours: hours,
      status: status,
      lastStudied: status != TopicStatus.notStarted
          ? now.subtract(Duration(days: status == TopicStatus.completed ? 4 : 2))
          : null,
      createdAt: now.subtract(const Duration(days: 7)),
    ));
  }

  // === HISTORY TOPICS ===
  final historyTopics = [
    ('Ancient Civilizations', 1.5, TopicStatus.notStarted),
    ('Medieval Europe', 2.0, TopicStatus.notStarted),
    ('World War I', 2.5, TopicStatus.notStarted),
    ('World War II', 3.0, TopicStatus.notStarted),
  ];
  for (final (name, hours, status) in historyTopics) {
    await db.addTopic(TopicModel(
      id: _uuid.v4(),
      subjectId: historyId,
      name: name,
      estimatedTimeHours: hours,
      status: status,
      createdAt: now.subtract(const Duration(days: 4)),
    ));
  }

  // === SAMPLE SCHEDULES ===
  final mathTopicsList = db.getTopicsForSubject(mathId);
  final physicsTopicsList = db.getTopicsForSubject(physicsId);

  if (mathTopicsList.length >= 3) {
    await db.addSchedule(ScheduleModel(
      id: _uuid.v4(),
      subjectId: mathId,
      topicId: mathTopicsList[2].id, // Trigonometry
      date: now,
      time: '10:00',
      durationHours: 2.0,
      createdAt: now,
    ));
  }

  if (physicsTopicsList.length >= 3) {
    await db.addSchedule(ScheduleModel(
      id: _uuid.v4(),
      subjectId: physicsId,
      topicId: physicsTopicsList[2].id, // Work, Energy & Power
      date: now.add(const Duration(days: 1)),
      time: '14:00',
      durationHours: 1.5,
      createdAt: now,
    ));

    await db.addSchedule(ScheduleModel(
      id: _uuid.v4(),
      subjectId: physicsId,
      topicId: physicsTopicsList[3].id, // Electrostatics
      date: now.add(const Duration(days: 3)),
      time: '09:00',
      durationHours: 3.0,
      createdAt: now,
    ));
  }
}
