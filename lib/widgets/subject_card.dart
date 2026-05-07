import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/subject_model.dart';
import '../models/topic_model.dart';
import '../theme/app_theme.dart';
import '../utils/app_constants.dart';

/// Card displaying a subject with its completion progress
class SubjectCard extends StatelessWidget {
  final SubjectModel subject;
  final List<TopicModel> topics;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final int animationDelay;

  const SubjectCard({
    super.key,
    required this.subject,
    required this.topics,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.animationDelay = 0,
  });

  double get _completionRate {
    if (topics.isEmpty) return 0;
    return topics.where((t) => t.status == TopicStatus.completed).length /
        topics.length;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = AppConstants.colorFromValue(subject.colorValue);
    final completed = topics.where((t) => t.status == TopicStatus.completed).length;
    final inProgress = topics.where((t) => t.status == TopicStatus.inProgress).length;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.grey.shade100,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    AppConstants.getIconData(subject.iconName),
                    color: color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppTheme.darkTextPrimary
                              : AppTheme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${topics.length} topics • $completed completed',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppTheme.darkTextSecondary
                              : AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') onEdit();
                    if (value == 'delete') onDelete();
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 18,
                              color: AppTheme.error),
                          SizedBox(width: 8),
                          Text('Delete',
                              style: TextStyle(color: AppTheme.error)),
                        ],
                      ),
                    ),
                  ],
                  child: Icon(
                    Icons.more_vert,
                    color: isDark
                        ? AppTheme.darkTextSecondary
                        : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _completionRate,
                backgroundColor: color.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _StatusChip(
                        count: inProgress,
                        label: 'In Progress',
                        color: AppTheme.warning),
                    const SizedBox(width: 6),
                    _StatusChip(
                        count: topics.length - completed - inProgress,
                        label: 'Pending',
                        color: AppTheme.textTertiary),
                  ],
                ),
                Text(
                  '${(_completionRate * 100).round()}%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      )
          .animate(delay: Duration(milliseconds: animationDelay))
          .fadeIn(duration: 350.ms)
          .slideX(begin: -0.1, end: 0, duration: 350.ms),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _StatusChip({
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
