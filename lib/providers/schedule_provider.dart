import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/schedule_model.dart';
import '../providers/database_provider.dart';

const _uuid = Uuid();

/// Notifier managing study schedules
class ScheduleNotifier extends StateNotifier<List<ScheduleModel>> {
  ScheduleNotifier(this._ref) : super([]) {
    _loadSchedules();
  }

  final Ref _ref;

  void _loadSchedules() {
    final db = _ref.read(databaseServiceProvider);
    state = db.getAllSchedules()
      ..sort((a, b) => a.scheduledDateTime.compareTo(b.scheduledDateTime));
  }

  void refresh() => _loadSchedules();

  /// Add a new schedule session
  Future<void> addSchedule({
    required String subjectId,
    required String topicId,
    required DateTime date,
    required String time,
    required double durationHours,
    String? notes,
  }) async {
    final db = _ref.read(databaseServiceProvider);
    final schedule = ScheduleModel(
      id: _uuid.v4(),
      subjectId: subjectId,
      topicId: topicId,
      date: date,
      time: time,
      durationHours: durationHours,
      createdAt: DateTime.now(),
      notes: notes,
    );
    await db.addSchedule(schedule);
    _loadSchedules();
  }

  /// Update an existing schedule
  Future<void> updateSchedule(ScheduleModel schedule) async {
    final db = _ref.read(databaseServiceProvider);
    await db.updateSchedule(schedule);
    _loadSchedules();
  }

  /// Mark a session as completed or not
  Future<void> toggleCompleted(String scheduleId) async {
    final db = _ref.read(databaseServiceProvider);
    final schedule = db.getAllSchedules().cast<ScheduleModel?>().firstWhere(
          (s) => s?.id == scheduleId,
          orElse: () => null,
        );
    if (schedule == null) return;
    await db.updateSchedule(schedule.copyWith(completed: !schedule.completed));
    _loadSchedules();
  }

  /// Delete a schedule
  Future<void> deleteSchedule(String id) async {
    final db = _ref.read(databaseServiceProvider);
    await db.deleteSchedule(id);
    _loadSchedules();
  }
}

/// Schedule list provider
final scheduleProvider =
    StateNotifierProvider<ScheduleNotifier, List<ScheduleModel>>((ref) {
  return ScheduleNotifier(ref);
});

/// Today's schedules
final todaysSchedulesProvider = Provider<List<ScheduleModel>>((ref) {
  final schedules = ref.watch(scheduleProvider);
  final now = DateTime.now();
  return schedules
      .where((s) =>
          s.date.year == now.year &&
          s.date.month == now.month &&
          s.date.day == now.day)
      .toList();
});

/// Upcoming schedules (future, not completed)
final upcomingSchedulesProvider = Provider<List<ScheduleModel>>((ref) {
  final schedules = ref.watch(scheduleProvider);
  final now = DateTime.now();
  return schedules
      .where((s) => !s.completed && s.scheduledDateTime.isAfter(now))
      .take(5)
      .toList();
});

/// Schedules for a specific date
final schedulesForDateProvider =
    Provider.family<List<ScheduleModel>, DateTime>((ref, date) {
  return ref.watch(scheduleProvider).where((s) {
    return s.date.year == date.year &&
        s.date.month == date.month &&
        s.date.day == date.day;
  }).toList();
});

/// Overdue schedules
final overdueSchedulesProvider = Provider<List<ScheduleModel>>((ref) {
  return ref.watch(scheduleProvider).where((s) => s.isOverdue).toList();
});
