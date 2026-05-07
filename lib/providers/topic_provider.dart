import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/topic_model.dart';
import '../providers/database_provider.dart';

const _uuid = Uuid();

/// Notifier managing the list of topics
class TopicNotifier extends StateNotifier<List<TopicModel>> {
  TopicNotifier(this._ref) : super([]) {
    _loadTopics();
  }

  final Ref _ref;

  void _loadTopics() {
    final db = _ref.read(databaseServiceProvider);
    state = db.getAllTopics()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  /// Refresh from database
  void refresh() => _loadTopics();

  /// Add a new topic
  Future<void> addTopic({
    required String subjectId,
    required String name,
    required double estimatedTimeHours,
    String? notes,
  }) async {
    final db = _ref.read(databaseServiceProvider);
    final topic = TopicModel(
      id: _uuid.v4(),
      subjectId: subjectId,
      name: name.trim(),
      estimatedTimeHours: estimatedTimeHours,
      createdAt: DateTime.now(),
      notes: notes,
    );
    await db.addTopic(topic);
    _loadTopics();
  }

  /// Update an existing topic
  Future<void> updateTopic(TopicModel topic) async {
    final db = _ref.read(databaseServiceProvider);
    await db.updateTopic(topic);
    _loadTopics();
  }

  /// Update topic status and set lastStudied when marking in-progress or completed
  Future<void> updateTopicStatus(String topicId, TopicStatus status) async {
    final db = _ref.read(databaseServiceProvider);
    final topic = db.getTopicById(topicId);
    if (topic == null) return;

    final updated = topic.copyWith(
      status: status,
      lastStudied: (status == TopicStatus.inProgress ||
              status == TopicStatus.completed)
          ? DateTime.now()
          : topic.lastStudied,
    );
    await db.updateTopic(updated);
    _loadTopics();
  }

  /// Delete a topic
  Future<void> deleteTopic(String id) async {
    final db = _ref.read(databaseServiceProvider);
    await db.deleteTopic(id);
    _loadTopics();
  }
}

/// Topic list provider
final topicProvider =
    StateNotifierProvider<TopicNotifier, List<TopicModel>>((ref) {
  return TopicNotifier(ref);
});

/// Topics filtered by subject
final topicsBySubjectProvider =
    Provider.family<List<TopicModel>, String>((ref, subjectId) {
  return ref
      .watch(topicProvider)
      .where((t) => t.subjectId == subjectId)
      .toList();
});

/// Subject completion percentage (0.0 – 1.0)
final subjectCompletionProvider =
    Provider.family<double, String>((ref, subjectId) {
  final topics = ref.watch(topicsBySubjectProvider(subjectId));
  if (topics.isEmpty) return 0.0;
  final completed =
      topics.where((t) => t.status == TopicStatus.completed).length;
  return completed / topics.length;
});

/// Total completion percentage across all topics
final totalCompletionProvider = Provider<double>((ref) {
  final topics = ref.watch(topicProvider);
  if (topics.isEmpty) return 0.0;
  final completed =
      topics.where((t) => t.status == TopicStatus.completed).length;
  return completed / topics.length;
});
