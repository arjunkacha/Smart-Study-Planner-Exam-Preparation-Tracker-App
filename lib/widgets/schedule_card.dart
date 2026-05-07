import 'package:flutter/material.dart';
import '../models/schedule_model.dart';
import '../models/subject_model.dart';
import '../models/topic_model.dart';
import '../theme/app_theme.dart';
import '../utils/app_constants.dart';

/// Card for a single study session
class ScheduleCard extends StatelessWidget {
  final ScheduleModel schedule;
  final SubjectModel? subject;
  final TopicModel? topic;
  final VoidCallback onToggleComplete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ScheduleCard({
    super.key,
    required this.schedule,
    required this.subject,
    required this.topic,
    required this.onToggleComplete,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = subject != null
        ? AppConstants.colorFromValue(subject!.colorValue)
        : AppTheme.primary;
    final isOverdue = schedule.isOverdue;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isOverdue
              ? AppTheme.error.withOpacity(0.3)
              : isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.grey.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onToggleComplete,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Time column
                Container(
                  width: 52,
                  child: Column(
                    children: [
                      Text(
                        AppConstants.formatTime(schedule.time)
                            .split(' ')[0],
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppTheme.darkTextPrimary
                              : AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        AppConstants.formatTime(schedule.time)
                            .split(' ')[1],
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppTheme.darkTextSecondary
                              : AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Timeline dot
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: schedule.completed
                              ? AppTheme.success
                              : isOverdue
                                  ? AppTheme.error
                                  : color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (isOverdue)
                            Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Overdue',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: AppTheme.error,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          Expanded(
                            child: Text(
                              topic?.name ?? 'Unknown Topic',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppTheme.darkTextPrimary
                                    : AppTheme.textPrimary,
                                decoration: schedule.completed
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              subject?.name ?? 'Unknown',
                              style: TextStyle(
                                fontSize: 10,
                                color: color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(Icons.timer_outlined,
                              size: 11,
                              color: isDark
                                  ? AppTheme.darkTextSecondary
                                  : AppTheme.textSecondary),
                          const SizedBox(width: 2),
                          Text(
                            AppConstants.formatDuration(schedule.durationHours),
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? AppTheme.darkTextSecondary
                                  : AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Actions
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: schedule.completed,
                      onChanged: (_) => onToggleComplete(),
                      activeColor: AppTheme.success,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') onEdit();
                        if (value == 'delete') onDelete();
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(children: [
                            Icon(Icons.edit_outlined, size: 16),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ]),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(children: [
                            Icon(Icons.delete_outline,
                                size: 16, color: AppTheme.error),
                            SizedBox(width: 8),
                            Text('Delete',
                                style: TextStyle(color: AppTheme.error)),
                          ]),
                        ),
                      ],
                      child: Icon(
                        Icons.more_vert,
                        size: 18,
                        color: isDark
                            ? AppTheme.darkTextSecondary
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
