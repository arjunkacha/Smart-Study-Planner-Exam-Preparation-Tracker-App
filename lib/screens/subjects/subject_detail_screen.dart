import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../providers/subject_provider.dart';
import '../../providers/topic_provider.dart';
import '../../models/subject_model.dart';
import '../../models/topic_model.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_constants.dart';
import '../../widgets/topic_tile.dart';
import '../../widgets/common_widgets.dart';

/// Detail screen for a single subject showing all its topics
class SubjectDetailScreen extends ConsumerWidget {
  final String subjectId;

  const SubjectDetailScreen({super.key, required this.subjectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subject = ref.watch(subjectByIdProvider(subjectId));
    final topics = ref.watch(topicsBySubjectProvider(subjectId));
    final completion = ref.watch(subjectCompletionProvider(subjectId));

    if (subject == null) {
      return const Scaffold(
        body: Center(child: Text('Subject not found')),
      );
    }

    final color = AppConstants.colorFromValue(subject.colorValue);
    final completedCount =
        topics.where((t) => t.status == TopicStatus.completed).length;
    final inProgressCount =
        topics.where((t) => t.status == TopicStatus.inProgress).length;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Custom gradient app bar
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                onPressed: () =>
                    context.push('/subjects/edit/${subject.id}'),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color, color.withOpacity(0.7)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40),
                        Row(
                          children: [
                            Icon(
                              AppConstants.getIconData(subject.iconName),
                              color: Colors.white,
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                subject.name,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Progress bar
                        LinearPercentIndicator(
                          percent: completion.clamp(0.0, 1.0),
                          lineHeight: 8,
                          backgroundColor: Colors.white.withOpacity(0.25),
                          progressColor: Colors.white,
                          barRadius: const Radius.circular(4),
                          padding: EdgeInsets.zero,
                          trailing: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text(
                              '${(completion * 100).round()}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$completedCount/${topics.length} topics completed',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status chips
                  Row(
                    children: [
                      _StatChip(
                        count: completedCount,
                        label: 'Completed',
                        color: AppTheme.success,
                      ),
                      const SizedBox(width: 8),
                      _StatChip(
                        count: inProgressCount,
                        label: 'In Progress',
                        color: AppTheme.warning,
                      ),
                      const SizedBox(width: 8),
                      _StatChip(
                        count: topics.length - completedCount - inProgressCount,
                        label: 'Not Started',
                        color: AppTheme.textTertiary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Topics header
                  SectionHeader(
                    title: 'Topics (${topics.length})',
                    actionLabel: 'Add Topic',
                    onAction: () =>
                        context.push('/subjects/$subjectId/add-topic'),
                  ),
                  const SizedBox(height: 12),

                  if (topics.isEmpty)
                    EmptyStateWidget(
                      icon: Icons.topic_outlined,
                      title: 'No Topics Yet',
                      subtitle:
                          'Add topics to track your syllabus coverage for ${subject.name}',
                      actionLabel: 'Add Topic',
                      onAction: () =>
                          context.push('/subjects/$subjectId/add-topic'),
                    )
                  else
                    ...topics.map((topic) => TopicTile(
                          topic: topic,
                          subjectColor: color,
                          onStatusChanged: (status) => ref
                              .read(topicProvider.notifier)
                              .updateTopicStatus(topic.id, status),
                          onEdit: () => context.push(
                              '/subjects/$subjectId/edit-topic/${topic.id}'),
                          onDelete: () =>
                              _confirmDeleteTopic(context, ref, topic),
                        )),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            context.push('/subjects/$subjectId/add-topic'),
        icon: const Icon(Icons.add),
        label: const Text('Add Topic'),
        backgroundColor: color,
      ),
    );
  }

  void _confirmDeleteTopic(
      BuildContext context, WidgetRef ref, TopicModel topic) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Topic?'),
        content: Text('Delete "${topic.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () {
              Navigator.pop(context);
              ref.read(topicProvider.notifier).deleteTopic(topic.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _StatChip({
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Add/Edit Topic Screen
class AddEditTopicScreen extends ConsumerStatefulWidget {
  final String subjectId;
  final String? topicId;

  const AddEditTopicScreen({
    super.key,
    required this.subjectId,
    this.topicId,
  });

  @override
  ConsumerState<AddEditTopicScreen> createState() => _AddEditTopicScreenState();
}

class _AddEditTopicScreenState extends ConsumerState<AddEditTopicScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  double _estimatedHours = 1.0;
  bool _isLoading = false;

  TopicModel? get _existingTopic =>
      widget.topicId != null
          ? ref.read(topicProvider).cast<TopicModel?>().firstWhere(
              (t) => t?.id == widget.topicId,
              orElse: () => null)
          : null;

  @override
  void initState() {
    super.initState();
    final existing = _existingTopic;
    if (existing != null) {
      _nameController.text = existing.name;
      _estimatedHours = existing.estimatedTimeHours;
      _notesController.text = existing.notes ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.topicId != null;
    final subject = ref.watch(subjectByIdProvider(widget.subjectId));
    final color = subject != null
        ? AppConstants.colorFromValue(subject.colorValue)
        : AppTheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Topic' : 'Add Topic'),
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
                if (subject != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                            AppConstants.getIconData(subject.iconName),
                            color: color,
                            size: 16),
                        const SizedBox(width: 6),
                        Text(
                          subject.name,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),

                // Topic name
                const Text('Topic Name',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'e.g., Quadratic Equations, Photosynthesis...',
                    prefixIcon: Icon(Icons.topic_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Topic name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Estimated time
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Estimated Study Time',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    Text(
                      AppConstants.formatDuration(_estimatedHours),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Slider(
                  value: _estimatedHours,
                  min: 0.25,
                  max: 10,
                  divisions: 39,
                  activeColor: color,
                  inactiveColor: color.withOpacity(0.2),
                  label: AppConstants.formatDuration(_estimatedHours),
                  onChanged: (v) => setState(() => _estimatedHours = v),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('15 min',
                        style: TextStyle(
                            fontSize: 11, color: AppTheme.textSecondary)),
                    Text('10 hours',
                        style: TextStyle(
                            fontSize: 11, color: AppTheme.textSecondary)),
                  ],
                ),
                const SizedBox(height: 24),

                // Notes
                const Text('Notes (Optional)',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Add any notes or resources...',
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 40),
                      child: Icon(Icons.notes_outlined),
                    ),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 32),

                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: color),
                    child: Text(isEditing ? 'Update Topic' : 'Add Topic'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      if (widget.topicId != null) {
        final existing = _existingTopic;
        if (existing != null) {
          await ref.read(topicProvider.notifier).updateTopic(
                existing.copyWith(
                  name: _nameController.text.trim(),
                  estimatedTimeHours: _estimatedHours,
                  notes: _notesController.text.trim().isNotEmpty
                      ? _notesController.text.trim()
                      : null,
                ),
              );
        }
      } else {
        await ref.read(topicProvider.notifier).addTopic(
              subjectId: widget.subjectId,
              name: _nameController.text.trim(),
              estimatedTimeHours: _estimatedHours,
              notes: _notesController.text.trim().isNotEmpty
                  ? _notesController.text.trim()
                  : null,
            );
      }

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.topicId != null
                ? 'Topic updated!'
                : 'Topic added!'),
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
