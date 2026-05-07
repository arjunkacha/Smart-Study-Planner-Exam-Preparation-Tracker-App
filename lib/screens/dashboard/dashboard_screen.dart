import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../providers/subject_provider.dart';
import '../../providers/topic_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../providers/connectivity_provider.dart';
import '../../models/topic_model.dart';
import '../../models/subject_model.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_constants.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/schedule_card.dart';

/// Main dashboard screen showing overview stats, progress, and insights
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjects = ref.watch(subjectProvider);
    final topics = ref.watch(topicProvider);
    final todaySchedules = ref.watch(todaysSchedulesProvider);
    final upcomingSchedules = ref.watch(upcomingSchedulesProvider);
    final totalCompletion = ref.watch(totalCompletionProvider);
    final isOnline = ref.watch(isOnlineProvider);

    final completedTopics =
        topics.where((t) => t.status == TopicStatus.completed).length;
    final pendingTopics =
        topics.where((t) => t.status != TopicStatus.completed).length;

    // Find most pending subject
    SubjectModel? mostPendingSubject;
    double lowestCompletion = 1.1;
    for (final subject in subjects) {
      final subjectTopics =
          topics.where((t) => t.subjectId == subject.id).toList();
      if (subjectTopics.isEmpty) continue;
      final completion =
          subjectTopics.where((t) => t.status == TopicStatus.completed).length /
              subjectTopics.length;
      if (completion < lowestCompletion) {
        lowestCompletion = completion;
        mostPendingSubject = subject;
      }
    }

    // Recently completed topic
    final recentlyCompleted = topics
        .where(
            (t) => t.status == TopicStatus.completed && t.lastStudied != null)
        .toList()
      ..sort((a, b) => b.lastStudied!.compareTo(a.lastStudied!));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF6C63FF),
                      Color(0xFF3D35CC),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getGreeting(),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white.withOpacity(0.75),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const Text(
                                  'Study Dashboard',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.school_rounded,
                                  color: Colors.white, size: 24),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Connectivity indicator
                        Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: isOnline
                                    ? AppTheme.secondary
                                    : AppTheme.warning,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              isOnline ? 'Online' : 'Offline Mode',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                ConnectivityBanner(isOnline: isOnline),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Progress Circle + Today
                      Row(
                        children: [
                          // Circular progress
                          CircularPercentIndicator(
                            radius: 70,
                            lineWidth: 10,
                            percent: totalCompletion.clamp(0.0, 1.0),
                            center: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${(totalCompletion * 100).round()}%',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.primary,
                                  ),
                                ),
                                const Text(
                                  'Done',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            progressColor: AppTheme.primary,
                            backgroundColor: AppTheme.primary.withOpacity(0.1),
                            circularStrokeCap: CircularStrokeCap.round,
                            animation: true,
                            animationDuration: 1200,
                          ).animate().fadeIn(duration: 500.ms),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _InsightRow(
                                  icon: Icons.check_circle_outline,
                                  color: AppTheme.success,
                                  label: 'Completed',
                                  value: '$completedTopics topics',
                                ),
                                const SizedBox(height: 8),
                                _InsightRow(
                                  icon: Icons.pending_outlined,
                                  color: AppTheme.warning,
                                  label: 'Pending',
                                  value: '$pendingTopics topics',
                                ),
                                const SizedBox(height: 8),
                                _InsightRow(
                                  icon: Icons.today_outlined,
                                  color: AppTheme.info,
                                  label: 'Today',
                                  value: '${todaySchedules.length} sessions',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Stats grid
                      const SectionHeader(title: 'Overview'),
                      const SizedBox(height: 12),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.4,
                        children: [
                          StatCard(
                            label: 'Subjects',
                            value: '${subjects.length}',
                            icon: Icons.library_books_outlined,
                            color: AppTheme.primary,
                            animationDelay: 0,
                          ),
                          StatCard(
                            label: 'Total Topics',
                            value: '${topics.length}',
                            icon: Icons.topic_outlined,
                            color: AppTheme.info,
                            animationDelay: 100,
                          ),
                          StatCard(
                            label: 'Completed',
                            value: '$completedTopics',
                            icon: Icons.task_alt_rounded,
                            color: AppTheme.success,
                            animationDelay: 200,
                          ),
                          StatCard(
                            label: "Today's Sessions",
                            value: '${todaySchedules.length}',
                            icon: Icons.event_note_outlined,
                            color: AppTheme.secondary,
                            animationDelay: 300,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Smart Insights
                      const SectionHeader(title: '💡 Smart Insights'),
                      const SizedBox(height: 12),
                      if (mostPendingSubject != null)
                        _InsightCard(
                          icon: Icons.warning_amber_rounded,
                          color: AppTheme.warning,
                          title: 'Needs Attention',
                          subtitle:
                              '${mostPendingSubject.name} has lowest completion (${(lowestCompletion * 100).round()}%)',
                        ),
                      if (recentlyCompleted.isNotEmpty)
                        _InsightCard(
                          icon: Icons.celebration_rounded,
                          color: AppTheme.success,
                          title: 'Recently Completed',
                          subtitle: recentlyCompleted.first.name,
                        ),
                      if (upcomingSchedules.isNotEmpty)
                        _InsightCard(
                          icon: Icons.schedule_rounded,
                          color: AppTheme.info,
                          title: 'Next Session',
                          subtitle:
                              '${AppConstants.formatDate(upcomingSchedules.first.date)} at ${AppConstants.formatTime(upcomingSchedules.first.time)}',
                        ),

                      // Recommended Next Topic
                      if (_getRecommendedTopic(topics, subjects) != null) ...[
                        const SizedBox(height: 12),
                        _RecommendedTopicCard(
                          topic: _getRecommendedTopic(topics, subjects)!,
                          subject: subjects.firstWhere(
                            (s) =>
                                s.id ==
                                _getRecommendedTopic(topics, subjects)!.subjectId,
                            orElse: () => subjects.first,
                          ),
                        ),
                      ],

                      if (upcomingSchedules.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        SectionHeader(
                          title: 'Upcoming Sessions',
                          actionLabel: 'See All',
                          onAction: () => context.go('/schedule'),
                        ),
                        const SizedBox(height: 12),
                        ...upcomingSchedules.take(3).map((s) {
                          final subject = subjects.cast<SubjectModel?>()
                              .firstWhere((sub) => sub?.id == s.subjectId,
                                  orElse: () => null);
                          final topic = topics.cast<TopicModel?>().firstWhere(
                              (t) => t?.id == s.topicId,
                              orElse: () => null);
                          return ScheduleCard(
                            schedule: s,
                            subject: subject,
                            topic: topic,
                            onToggleComplete: () {},
                            onEdit: () {},
                            onDelete: () {},
                          );
                        }),
                      ],
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning! 🌅';
    if (hour < 17) return 'Good afternoon! ☀️';
    return 'Good evening! 🌙';
  }

  TopicModel? _getRecommendedTopic(
      List<TopicModel> topics, List<SubjectModel> subjects) {
    // Suggest: not started, belonging to subject with lowest completion
    final notStarted =
        topics.where((t) => t.status == TopicStatus.notStarted).toList();
    if (notStarted.isEmpty) {
      final inProgress =
          topics.where((t) => t.status == TopicStatus.inProgress).toList();
      return inProgress.isNotEmpty ? inProgress.first : null;
    }
    return notStarted.first;
  }
}

class _InsightRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _InsightRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.textSecondary)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _InsightCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary)),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color:
                        isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

class _RecommendedTopicCard extends StatelessWidget {
  final TopicModel topic;
  final SubjectModel subject;

  const _RecommendedTopicCard({required this.topic, required this.subject});

  @override
  Widget build(BuildContext context) {
    final color = AppConstants.colorFromValue(subject.colorValue);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.15),
            AppTheme.primary.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.lightbulb_rounded,
                color: AppTheme.warning, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '⭐ Recommended Next Topic',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  topic.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  subject.name,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 14, color: color),
        ],
      ),
    ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.2, end: 0);
  }
}
