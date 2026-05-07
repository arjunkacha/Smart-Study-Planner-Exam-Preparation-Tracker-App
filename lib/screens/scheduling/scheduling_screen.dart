import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../providers/schedule_provider.dart';
import '../../providers/subject_provider.dart';
import '../../providers/topic_provider.dart';
import '../../models/schedule_model.dart';
import '../../models/subject_model.dart';
import '../../models/topic_model.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_constants.dart';
import '../../widgets/schedule_card.dart';
import '../../widgets/common_widgets.dart';

/// Study scheduling screen with calendar view and daily list
class SchedulingScreen extends ConsumerStatefulWidget {
  const SchedulingScreen({super.key});

  @override
  ConsumerState<SchedulingScreen> createState() => _SchedulingScreenState();
}

class _SchedulingScreenState extends ConsumerState<SchedulingScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;

  @override
  Widget build(BuildContext context) {
    final schedules = ref.watch(schedulesForDateProvider(_selectedDay));
    final allSchedules = ref.watch(scheduleProvider);
    final subjects = ref.watch(subjectProvider);
    final topics = ref.watch(topicProvider);
    final overdueSchedules = ref.watch(overdueSchedulesProvider);

    // Map dates that have events
    Map<DateTime, List<ScheduleModel>> eventMap = {};
    for (final s in allSchedules) {
      final key = DateTime(s.date.year, s.date.month, s.date.day);
      eventMap[key] = [...(eventMap[key] ?? []), s];
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Schedule'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            onPressed: () => context.push('/schedule/add'),
            tooltip: 'Add Session',
          ),
        ],
      ),
      body: Column(
        children: [
          // Overdue alert
          if (overdueSchedules.isNotEmpty)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.error.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.error.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: AppTheme.error, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    '${overdueSchedules.length} overdue session${overdueSchedules.length > 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          // Calendar
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2035, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: (day) {
              final key = DateTime(day.year, day.month, day.day);
              return eventMap[key] ?? [];
            },
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              });
            },
            onFormatChanged: (format) =>
                setState(() => _calendarFormat = format),
            onPageChanged: (focusedDay) => _focusedDay = focusedDay,
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              todayTextStyle:
                  const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700),
              selectedDecoration: const BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
              ),
              markerDecoration: const BoxDecoration(
                color: AppTheme.secondary,
                shape: BoxShape.circle,
              ),
              markerSize: 5,
              outsideDaysVisible: false,
            ),
            headerStyle: const HeaderStyle(
              formatButtonDecoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              formatButtonTextStyle: TextStyle(color: Colors.white, fontSize: 12),
              titleCentered: true,
            ),
          ),
          const Divider(height: 1),

          // Sessions for selected day
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppConstants.formatDate(_selectedDay),
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700),
                ),
                Text(
                  '${schedules.length} session${schedules.length != 1 ? 's' : ''}',
                  style: const TextStyle(
                      fontSize: 13, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),

          Expanded(
            child: schedules.isEmpty
                ? EmptyStateWidget(
                    icon: Icons.event_available_outlined,
                    title: 'No Sessions',
                    subtitle:
                        'No study sessions scheduled for ${AppConstants.formatDate(_selectedDay)}',
                    actionLabel: 'Schedule Session',
                    onAction: () => context.push('/schedule/add'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: schedules.length,
                    itemBuilder: (_, i) {
                      final s = schedules[i];
                      final subject =
                          subjects.cast<SubjectModel?>().firstWhere(
                              (sub) => sub?.id == s.subjectId,
                              orElse: () => null);
                      final topic = topics.cast<TopicModel?>().firstWhere(
                          (t) => t?.id == s.topicId,
                          orElse: () => null);
                      return ScheduleCard(
                        schedule: s,
                        subject: subject,
                        topic: topic,
                        onToggleComplete: () => ref
                            .read(scheduleProvider.notifier)
                            .toggleCompleted(s.id),
                        onEdit: () => context.push('/schedule/edit/${s.id}'),
                        onDelete: () =>
                            _confirmDelete(context, ref, s),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/schedule/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add Session'),
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, ScheduleModel schedule) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Session?'),
        content:
            const Text('Are you sure you want to delete this study session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(scheduleProvider.notifier)
                  .deleteSchedule(schedule.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Add/Edit Schedule Session Screen
class AddEditScheduleScreen extends ConsumerStatefulWidget {
  final String? scheduleId;

  const AddEditScheduleScreen({super.key, this.scheduleId});

  @override
  ConsumerState<AddEditScheduleScreen> createState() =>
      _AddEditScheduleScreenState();
}

class _AddEditScheduleScreenState
    extends ConsumerState<AddEditScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  String? _selectedSubjectId;
  String? _selectedTopicId;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  double _durationHours = 1.0;
  bool _isLoading = false;

  ScheduleModel? get _existingSchedule => widget.scheduleId != null
      ? ref.read(scheduleProvider).cast<ScheduleModel?>().firstWhere(
          (s) => s?.id == widget.scheduleId,
          orElse: () => null)
      : null;

  @override
  void initState() {
    super.initState();
    final existing = _existingSchedule;
    if (existing != null) {
      _selectedSubjectId = existing.subjectId;
      _selectedTopicId = existing.topicId;
      _selectedDate = existing.date;
      final parts = existing.time.split(':');
      _selectedTime = TimeOfDay(
          hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      _durationHours = existing.durationHours;
      _notesController.text = existing.notes ?? '';
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subjects = ref.watch(subjectProvider);
    final topics = _selectedSubjectId != null
        ? ref.watch(topicsBySubjectProvider(_selectedSubjectId!))
        : <TopicModel>[];
    final isEditing = widget.scheduleId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Session' : 'Schedule Session'),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subject
                const Text('Subject',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedSubjectId,
                  decoration: const InputDecoration(
                    hintText: 'Select a subject',
                    prefixIcon: Icon(Icons.library_books_outlined),
                  ),
                  items: subjects.map((s) {
                    final color = AppConstants.colorFromValue(s.colorValue);
                    return DropdownMenuItem(
                      value: s.id,
                      child: Row(
                        children: [
                          Icon(AppConstants.getIconData(s.iconName),
                              color: color, size: 16),
                          const SizedBox(width: 8),
                          Text(s.name),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() {
                    _selectedSubjectId = v;
                    _selectedTopicId = null;
                  }),
                  validator: (v) =>
                      v == null ? 'Please select a subject' : null,
                ),
                const SizedBox(height: 16),

                // Topic
                const Text('Topic',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedTopicId,
                  decoration: const InputDecoration(
                    hintText: 'Select a topic',
                    prefixIcon: Icon(Icons.topic_outlined),
                  ),
                  items: topics.map((t) {
                    return DropdownMenuItem(
                      value: t.id,
                      child: Text(t.name,
                          overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (v) =>
                      setState(() => _selectedTopicId = v),
                  validator: (v) =>
                      v == null ? 'Please select a topic' : null,
                ),
                const SizedBox(height: 16),

                // Date
                const Text('Date',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).inputDecorationTheme.fillColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 20, color: AppTheme.textSecondary),
                        const SizedBox(width: 12),
                        Text(
                          AppConstants.formatDate(_selectedDate),
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Time
                const Text('Time',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickTime,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).inputDecorationTheme.fillColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time_outlined,
                            size: 20, color: AppTheme.textSecondary),
                        const SizedBox(width: 12),
                        Text(
                          _selectedTime.format(context),
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Duration
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Duration',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    Text(
                      AppConstants.formatDuration(_durationHours),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Slider(
                  value: _durationHours,
                  min: 0.25,
                  max: 8,
                  divisions: 31,
                  activeColor: AppTheme.primary,
                  inactiveColor: AppTheme.primary.withOpacity(0.2),
                  label: AppConstants.formatDuration(_durationHours),
                  onChanged: (v) => setState(() => _durationHours = v),
                ),
                const SizedBox(height: 16),

                // Notes
                const Text('Notes (Optional)',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _notesController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'Session notes...',
                  ),
                ),
                const SizedBox(height: 32),

                // Save
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _save,
                    child: Text(
                        isEditing ? 'Update Session' : 'Schedule Session'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  String get _timeString {
    final h = _selectedTime.hour.toString().padLeft(2, '0');
    final m = _selectedTime.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      if (widget.scheduleId != null) {
        final existing = _existingSchedule;
        if (existing != null) {
          await ref.read(scheduleProvider.notifier).updateSchedule(
                existing.copyWith(
                  subjectId: _selectedSubjectId,
                  topicId: _selectedTopicId,
                  date: _selectedDate,
                  time: _timeString,
                  durationHours: _durationHours,
                  notes: _notesController.text.trim().isNotEmpty
                      ? _notesController.text.trim()
                      : null,
                ),
              );
        }
      } else {
        await ref.read(scheduleProvider.notifier).addSchedule(
              subjectId: _selectedSubjectId!,
              topicId: _selectedTopicId!,
              date: _selectedDate,
              time: _timeString,
              durationHours: _durationHours,
              notes: _notesController.text.trim().isNotEmpty
                  ? _notesController.text.trim()
                  : null,
            );
      }

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.scheduleId != null
                ? 'Session updated!'
                : 'Session scheduled!'),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
