import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../providers/subject_provider.dart';
import '../../providers/topic_provider.dart';
import '../../models/topic_model.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_constants.dart';
import '../../widgets/common_widgets.dart';

/// Progress tracking screen showing subject-wise and overall completion
class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subjects = ref.watch(subjectProvider);
    final topics = ref.watch(topicProvider);
    final totalCompletion = ref.watch(totalCompletionProvider);

    final completedTopics =
        topics.where((t) => t.status == TopicStatus.completed).length;
    final inProgressTopics =
        topics.where((t) => t.status == TopicStatus.inProgress).length;
    final notStartedTopics =
        topics.where((t) => t.status == TopicStatus.notStarted).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Tracker'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primary,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'By Subject'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Overview Tab
          _buildOverviewTab(
            totalCompletion: totalCompletion,
            completedTopics: completedTopics,
            inProgressTopics: inProgressTopics,
            notStartedTopics: notStartedTopics,
            totalTopics: topics.length,
            subjects: subjects.length,
          ),
          // By Subject Tab
          subjects.isEmpty
              ? const EmptyStateWidget(
                  icon: Icons.bar_chart_outlined,
                  title: 'No Subjects',
                  subtitle: 'Add subjects to track your progress',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: subjects.length,
                  itemBuilder: (_, i) {
                    final subject = subjects[i];
                    final subjectTopics = ref
                        .watch(topicsBySubjectProvider(subject.id));
                    final completion = ref
                        .watch(subjectCompletionProvider(subject.id));
                    return _SubjectProgressCard(
                      subjectName: subject.name,
                      iconName: subject.iconName,
                      colorValue: subject.colorValue,
                      topics: subjectTopics,
                      completion: completion,
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab({
    required double totalCompletion,
    required int completedTopics,
    required int inProgressTopics,
    required int notStartedTopics,
    required int totalTopics,
    required int subjects,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Big circular progress
          Center(
            child: CircularPercentIndicator(
              radius: 90,
              lineWidth: 14,
              percent: totalCompletion.clamp(0.0, 1.0),
              center: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${(totalCompletion * 100).round()}%',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.primary,
                    ),
                  ),
                  const Text(
                    'Overall',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              progressColor: AppTheme.primary,
              backgroundColor: AppTheme.primary.withOpacity(0.1),
              circularStrokeCap: CircularStrokeCap.round,
              animation: true,
              animationDuration: 1500,
              footer: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  '$completedTopics of $totalTopics topics completed',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Status breakdown
          const SectionHeader(title: 'Status Breakdown'),
          const SizedBox(height: 16),
          _StatusProgressRow(
            label: 'Completed',
            count: completedTopics,
            total: totalTopics,
            color: AppTheme.success,
            icon: Icons.check_circle_rounded,
          ),
          const SizedBox(height: 12),
          _StatusProgressRow(
            label: 'In Progress',
            count: inProgressTopics,
            total: totalTopics,
            color: AppTheme.warning,
            icon: Icons.timelapse_rounded,
          ),
          const SizedBox(height: 12),
          _StatusProgressRow(
            label: 'Not Started',
            count: notStartedTopics,
            total: totalTopics,
            color: AppTheme.textTertiary,
            icon: Icons.radio_button_unchecked_rounded,
          ),
          const SizedBox(height: 32),

          // Summary cards
          const SectionHeader(title: 'Study Summary'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  label: 'Subjects',
                  value: '$subjects',
                  icon: Icons.library_books_outlined,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  label: 'Total Topics',
                  value: '$totalTopics',
                  icon: Icons.topic_outlined,
                  color: AppTheme.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  label: 'Completed',
                  value: '$completedTopics',
                  icon: Icons.task_alt_rounded,
                  color: AppTheme.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  label: 'Remaining',
                  value: '${totalTopics - completedTopics}',
                  icon: Icons.pending_actions_outlined,
                  color: AppTheme.accent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusProgressRow extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;
  final IconData icon;

  const _StatusProgressRow({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final percent = total > 0 ? count / total : 0.0;

    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        SizedBox(
          width: 90,
          child: Text(label,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600)),
        ),
        Expanded(
          child: LinearPercentIndicator(
            percent: percent.clamp(0.0, 1.0),
            lineHeight: 8,
            backgroundColor: color.withOpacity(0.1),
            progressColor: color,
            barRadius: const Radius.circular(4),
            padding: EdgeInsets.zero,
            animation: true,
            animationDuration: 1000,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _SubjectProgressCard extends StatelessWidget {
  final String subjectName;
  final String iconName;
  final int colorValue;
  final List<TopicModel> topics;
  final double completion;

  const _SubjectProgressCard({
    required this.subjectName,
    required this.iconName,
    required this.colorValue,
    required this.topics,
    required this.completion,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppConstants.colorFromValue(colorValue);
    final completedCount =
        topics.where((t) => t.status == TopicStatus.completed).length;
    final inProgressCount =
        topics.where((t) => t.status == TopicStatus.inProgress).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppTheme.darkSurface
            : AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(AppConstants.getIconData(iconName),
                    color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  subjectName,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '${(completion * 100).round()}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearPercentIndicator(
            percent: completion.clamp(0.0, 1.0),
            lineHeight: 8,
            backgroundColor: color.withOpacity(0.1),
            progressColor: color,
            barRadius: const Radius.circular(4),
            padding: EdgeInsets.zero,
            animation: true,
            animationDuration: 1000,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _MiniStatusChip(
                  count: completedCount, label: 'Done', color: AppTheme.success),
              const SizedBox(width: 8),
              _MiniStatusChip(
                  count: inProgressCount,
                  label: 'In Progress',
                  color: AppTheme.warning),
              const SizedBox(width: 8),
              _MiniStatusChip(
                  count: topics.length - completedCount - inProgressCount,
                  label: 'Pending',
                  color: AppTheme.textTertiary),
              const Spacer(),
              Text(
                '$completedCount/${topics.length} topics',
                style: const TextStyle(
                    fontSize: 11, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStatusChip extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _MiniStatusChip(
      {required this.count, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$count $label',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
