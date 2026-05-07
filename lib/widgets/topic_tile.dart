import 'package:flutter/material.dart';
import '../models/topic_model.dart';
import '../theme/app_theme.dart';

/// Tile widget displaying a single topic with status controls
class TopicTile extends StatelessWidget {
  final TopicModel topic;
  final Color subjectColor;
  final Function(TopicStatus) onStatusChanged;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TopicTile({
    super.key,
    required this.topic,
    required this.subjectColor,
    required this.onStatusChanged,
    required this.onEdit,
    required this.onDelete,
  });

  Color get _statusColor {
    switch (topic.status) {
      case TopicStatus.completed:
        return AppTheme.success;
      case TopicStatus.inProgress:
        return AppTheme.warning;
      case TopicStatus.notStarted:
        return AppTheme.textTertiary;
    }
  }

  IconData get _statusIcon {
    switch (topic.status) {
      case TopicStatus.completed:
        return Icons.check_circle_rounded;
      case TopicStatus.inProgress:
        return Icons.timelapse_rounded;
      case TopicStatus.notStarted:
        return Icons.radio_button_unchecked_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurfaceVariant : AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: _statusColor, width: 3),
        ),
      ),
      child: Row(
        children: [
          // Status toggle button
          GestureDetector(
            onTap: () => _showStatusPicker(context),
            child: Icon(_statusIcon, color: _statusColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topic.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppTheme.darkTextPrimary
                        : AppTheme.textPrimary,
                    decoration: topic.status == TopicStatus.completed
                        ? TextDecoration.lineThrough
                        : null,
                    decorationColor: AppTheme.success,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.access_time,
                        size: 11,
                        color: isDark
                            ? AppTheme.darkTextSecondary
                            : AppTheme.textSecondary),
                    const SizedBox(width: 3),
                    Text(
                      _formatEstimatedTime(topic.estimatedTimeHours),
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppTheme.darkTextSecondary
                            : AppTheme.textSecondary,
                      ),
                    ),
                    if (topic.lastStudied != null) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.history,
                          size: 11,
                          color: isDark
                              ? AppTheme.darkTextSecondary
                              : AppTheme.textSecondary),
                      const SizedBox(width: 3),
                      Text(
                        'Last: ${_formatDate(topic.lastStudied!)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppTheme.darkTextSecondary
                              : AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') onEdit();
              if (value == 'delete') onDelete();
            },
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  Text('Delete', style: TextStyle(color: AppTheme.error)),
                ]),
              ),
            ],
            child: Icon(
              Icons.more_vert,
              size: 18,
              color:
                  isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showStatusPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Update Status',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            ...TopicStatus.values.map(
              (s) => ListTile(
                leading: Icon(_iconForStatus(s), color: _colorForStatus(s)),
                title: Text(s.displayName),
                trailing: topic.status == s
                    ? const Icon(Icons.check, color: AppTheme.primary)
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  onStatusChanged(s);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForStatus(TopicStatus s) {
    switch (s) {
      case TopicStatus.notStarted:
        return Icons.radio_button_unchecked_rounded;
      case TopicStatus.inProgress:
        return Icons.timelapse_rounded;
      case TopicStatus.completed:
        return Icons.check_circle_rounded;
    }
  }

  Color _colorForStatus(TopicStatus s) {
    switch (s) {
      case TopicStatus.notStarted:
        return AppTheme.textTertiary;
      case TopicStatus.inProgress:
        return AppTheme.warning;
      case TopicStatus.completed:
        return AppTheme.success;
    }
  }

  String _formatEstimatedTime(double hours) {
    if (hours < 1) return '${(hours * 60).round()}m';
    final h = hours.floor();
    final m = ((hours - h) * 60).round();
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
