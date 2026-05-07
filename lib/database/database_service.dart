import 'package:hive_flutter/hive_flutter.dart';
import '../models/subject_model.dart';
import '../models/topic_model.dart';
import '../models/schedule_model.dart';

/// Manages all Hive database operations for the app.
/// Provides CRUD functionality for subjects, topics, and schedules.
class DatabaseService {
  static const String _subjectBoxName = 'subjects';
  static const String _topicBoxName = 'topics';
  static const String _scheduleBoxName = 'schedules';

  // Hive box references
  late Box<SubjectModel> _subjectBox;
  late Box<TopicModel> _topicBox;
  late Box<ScheduleModel> _scheduleBox;

  bool _isInitialized = false;

  /// Initialize Hive and open all required boxes
  Future<void> init() async {
    if (_isInitialized) return;

    await Hive.initFlutter();

    // Register adapters if not already registered
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(SubjectModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TopicStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(TopicModelAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(ScheduleModelAdapter());
    }

    // Open boxes
    _subjectBox = await Hive.openBox<SubjectModel>(_subjectBoxName);
    _topicBox = await Hive.openBox<TopicModel>(_topicBoxName);
    _scheduleBox = await Hive.openBox<ScheduleModel>(_scheduleBoxName);

    _isInitialized = true;
  }

  // ────────────────────────── SUBJECT OPERATIONS ──────────────────────────

  /// Get all subjects
  List<SubjectModel> getAllSubjects() => _subjectBox.values.toList();

  /// Get subject by id
  SubjectModel? getSubjectById(String id) {
    try {
      return _subjectBox.values.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Add a new subject
  Future<void> addSubject(SubjectModel subject) async {
    await _subjectBox.put(subject.id, subject);
  }

  /// Update existing subject
  Future<void> updateSubject(SubjectModel subject) async {
    await _subjectBox.put(subject.id, subject);
  }

  /// Delete subject and all its topics/schedules
  Future<void> deleteSubject(String subjectId) async {
    await _subjectBox.delete(subjectId);
    // Cascade delete topics
    final topicKeys = _topicBox.values
        .where((t) => t.subjectId == subjectId)
        .map((t) => t.id)
        .toList();
    for (final key in topicKeys) {
      await _topicBox.delete(key);
    }
    // Cascade delete schedules
    final scheduleKeys = _scheduleBox.values
        .where((s) => s.subjectId == subjectId)
        .map((s) => s.id)
        .toList();
    for (final key in scheduleKeys) {
      await _scheduleBox.delete(key);
    }
  }

  // ────────────────────────── TOPIC OPERATIONS ──────────────────────────

  /// Get all topics
  List<TopicModel> getAllTopics() => _topicBox.values.toList();

  /// Get topics for a specific subject
  List<TopicModel> getTopicsForSubject(String subjectId) =>
      _topicBox.values.where((t) => t.subjectId == subjectId).toList();

  /// Get topic by id
  TopicModel? getTopicById(String id) {
    try {
      return _topicBox.values.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Add a new topic
  Future<void> addTopic(TopicModel topic) async {
    await _topicBox.put(topic.id, topic);
  }

  /// Update existing topic
  Future<void> updateTopic(TopicModel topic) async {
    await _topicBox.put(topic.id, topic);
  }

  /// Delete topic and its schedules
  Future<void> deleteTopic(String topicId) async {
    await _topicBox.delete(topicId);
    final scheduleKeys = _scheduleBox.values
        .where((s) => s.topicId == topicId)
        .map((s) => s.id)
        .toList();
    for (final key in scheduleKeys) {
      await _scheduleBox.delete(key);
    }
  }

  // ────────────────────────── SCHEDULE OPERATIONS ──────────────────────────

  /// Get all schedules
  List<ScheduleModel> getAllSchedules() => _scheduleBox.values.toList();

  /// Get schedules for a specific date
  List<ScheduleModel> getSchedulesForDate(DateTime date) =>
      _scheduleBox.values
          .where((s) =>
              s.date.year == date.year &&
              s.date.month == date.month &&
              s.date.day == date.day)
          .toList();

  /// Get today's schedules
  List<ScheduleModel> getTodaysSchedules() =>
      getSchedulesForDate(DateTime.now());

  /// Get upcoming schedules (future and today, not completed)
  List<ScheduleModel> getUpcomingSchedules() {
    final now = DateTime.now();
    return _scheduleBox.values
        .where((s) => !s.completed && s.scheduledDateTime.isAfter(now))
        .toList()
      ..sort((a, b) => a.scheduledDateTime.compareTo(b.scheduledDateTime));
  }

  /// Add a new schedule
  Future<void> addSchedule(ScheduleModel schedule) async {
    await _scheduleBox.put(schedule.id, schedule);
  }

  /// Update existing schedule
  Future<void> updateSchedule(ScheduleModel schedule) async {
    await _scheduleBox.put(schedule.id, schedule);
  }

  /// Delete schedule
  Future<void> deleteSchedule(String scheduleId) async {
    await _scheduleBox.delete(scheduleId);
  }

  // ────────────────────────── ANALYTICS HELPERS ──────────────────────────

  /// Calculate completion percentage for a subject (0.0 – 1.0)
  double getSubjectCompletionPercentage(String subjectId) {
    final topics = getTopicsForSubject(subjectId);
    if (topics.isEmpty) return 0.0;
    final completed =
        topics.where((t) => t.status == TopicStatus.completed).length;
    return completed / topics.length;
  }

  /// Get total completion percentage across all subjects (0.0 – 1.0)
  double getTotalCompletionPercentage() {
    final topics = getAllTopics();
    if (topics.isEmpty) return 0.0;
    final completed =
        topics.where((t) => t.status == TopicStatus.completed).length;
    return completed / topics.length;
  }

  /// Clear all data (used for data reset)
  Future<void> clearAll() async {
    await _subjectBox.clear();
    await _topicBox.clear();
    await _scheduleBox.clear();
  }

  /// Export all data as Map
  Map<String, dynamic> exportData() => {
        'subjects': getAllSubjects().map((s) => s.toMap()).toList(),
        'topics': getAllTopics().map((t) => t.toMap()).toList(),
        'schedules': getAllSchedules().map((s) => s.toMap()).toList(),
        'exportedAt': DateTime.now().toIso8601String(),
      };

  /// Import data from Map
  Future<void> importData(Map<String, dynamic> data) async {
    await clearAll();
    for (final s in (data['subjects'] as List)) {
      await addSubject(SubjectModel.fromMap(s));
    }
    for (final t in (data['topics'] as List)) {
      await addTopic(TopicModel.fromMap(t));
    }
    for (final sc in (data['schedules'] as List)) {
      await addSchedule(ScheduleModel.fromMap(sc));
    }
  }
}
