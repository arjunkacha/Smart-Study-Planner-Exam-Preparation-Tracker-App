import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/subject_model.dart';
import '../providers/database_provider.dart';

const _uuid = Uuid();

/// Notifier managing the list of subjects
class SubjectNotifier extends StateNotifier<List<SubjectModel>> {
  SubjectNotifier(this._ref) : super([]) {
    _loadSubjects();
  }

  final Ref _ref;

  void _loadSubjects() {
    final db = _ref.read(databaseServiceProvider);
    state = db.getAllSubjects()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  /// Refresh from database
  void refresh() => _loadSubjects();

  /// Add a new subject
  Future<void> addSubject({
    required String name,
    required int colorValue,
    required String iconName,
  }) async {
    final db = _ref.read(databaseServiceProvider);
    final subject = SubjectModel(
      id: _uuid.v4(),
      name: name.trim(),
      colorValue: colorValue,
      iconName: iconName,
      createdAt: DateTime.now(),
    );
    await db.addSubject(subject);
    _loadSubjects();
  }

  /// Update an existing subject
  Future<void> updateSubject(SubjectModel subject) async {
    final db = _ref.read(databaseServiceProvider);
    await db.updateSubject(subject);
    _loadSubjects();
  }

  /// Delete a subject and all its associated data
  Future<void> deleteSubject(String id) async {
    final db = _ref.read(databaseServiceProvider);
    await db.deleteSubject(id);
    _loadSubjects();
  }
}

/// Subject list provider
final subjectProvider =
    StateNotifierProvider<SubjectNotifier, List<SubjectModel>>((ref) {
  return SubjectNotifier(ref);
});

/// Provider that returns a single subject by id
final subjectByIdProvider = Provider.family<SubjectModel?, String>((ref, id) {
  final subjects = ref.watch(subjectProvider);
  try {
    return subjects.firstWhere((s) => s.id == id);
  } catch (_) {
    return null;
  }
});
