import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/subject_provider.dart';
import '../../providers/topic_provider.dart';
import '../../models/topic_model.dart';
import '../../models/subject_model.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_constants.dart';

/// Search and filter screen for topics
class SearchFilterScreen extends ConsumerStatefulWidget {
  const SearchFilterScreen({super.key});

  @override
  ConsumerState<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends ConsumerState<SearchFilterScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _filterSubjectId;
  TopicStatus? _filterStatus;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subjects = ref.watch(subjectProvider);
    final allTopics = ref.watch(topicProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Apply filters
    final filteredTopics = allTopics.where((topic) {
      // Search filter
      if (_searchQuery.isNotEmpty &&
          !topic.name.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      // Subject filter
      if (_filterSubjectId != null && topic.subjectId != _filterSubjectId) {
        return false;
      }
      // Status filter
      if (_filterStatus != null && topic.status != _filterStatus) {
        return false;
      }
      return true;
    }).toList();

    final hasActiveFilters =
        _filterSubjectId != null || _filterStatus != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search & Filter'),
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextFormField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search topics...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          const SizedBox(height: 8),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Clear filters
                if (hasActiveFilters)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      avatar: const Icon(Icons.clear, size: 14),
                      label: const Text('Clear'),
                      onPressed: () => setState(() {
                        _filterSubjectId = null;
                        _filterStatus = null;
                      }),
                      backgroundColor: AppTheme.error.withOpacity(0.1),
                      labelStyle: const TextStyle(
                          color: AppTheme.error, fontWeight: FontWeight.w600),
                    ),
                  ),

                // Subject filters
                ...subjects.map((s) {
                  final color = AppConstants.colorFromValue(s.colorValue);
                  final isSelected = _filterSubjectId == s.id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      avatar: Icon(AppConstants.getIconData(s.iconName),
                          size: 14, color: isSelected ? color : null),
                      label: Text(s.name),
                      selected: isSelected,
                      selectedColor: color.withOpacity(0.15),
                      checkmarkColor: color,
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isSelected ? color : null,
                      ),
                      onSelected: (selected) => setState(() {
                        _filterSubjectId = selected ? s.id : null;
                      }),
                    ),
                  );
                }),
              ],
            ),
          ),

          // Status filter row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Row(
              children: TopicStatus.values.map((status) {
                Color statusColor;
                switch (status) {
                  case TopicStatus.completed:
                    statusColor = AppTheme.success;
                    break;
                  case TopicStatus.inProgress:
                    statusColor = AppTheme.warning;
                    break;
                  case TopicStatus.notStarted:
                    statusColor = AppTheme.textTertiary;
                    break;
                }
                final isSelected = _filterStatus == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(status.displayName),
                    selected: isSelected,
                    selectedColor: statusColor.withOpacity(0.15),
                    checkmarkColor: statusColor,
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: isSelected ? statusColor : null,
                      fontSize: 12,
                    ),
                    onSelected: (selected) => setState(() {
                      _filterStatus = selected ? status : null;
                    }),
                  ),
                );
              }).toList(),
            ),
          ),

          // Results header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text(
                  '${filteredTopics.length} result${filteredTopics.length != 1 ? 's' : ''}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
                if (hasActiveFilters || _searchQuery.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Filtered',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Results list
          Expanded(
            child: filteredTopics.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded,
                            size: 56,
                            color: AppTheme.textTertiary.withOpacity(0.5)),
                        const SizedBox(height: 12),
                        const Text(
                          'No topics found',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const Text(
                          'Try adjusting your search or filters',
                          style: TextStyle(
                              fontSize: 13, color: AppTheme.textTertiary),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    itemCount: filteredTopics.length,
                    itemBuilder: (_, i) {
                      final topic = filteredTopics[i];
                      final subject =
                          subjects.cast<SubjectModel?>().firstWhere(
                              (s) => s?.id == topic.subjectId,
                              orElse: () => null);
                      return _SearchResultTile(
                          topic: topic, subject: subject);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final TopicModel topic;
  final SubjectModel? subject;

  const _SearchResultTile({required this.topic, required this.subject});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = subject != null
        ? AppConstants.colorFromValue(subject!.colorValue)
        : AppTheme.primary;

    Color statusColor;
    IconData statusIcon;
    switch (topic.status) {
      case TopicStatus.completed:
        statusColor = AppTheme.success;
        statusIcon = Icons.check_circle_rounded;
        break;
      case TopicStatus.inProgress:
        statusColor = AppTheme.warning;
        statusIcon = Icons.timelapse_rounded;
        break;
      case TopicStatus.notStarted:
        statusColor = AppTheme.textTertiary;
        statusIcon = Icons.radio_button_unchecked_rounded;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.grey.shade100,
        ),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 20),
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
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    if (subject != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          subject!.name,
                          style: TextStyle(
                            fontSize: 10,
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        topic.status.displayName,
                        style: TextStyle(
                          fontSize: 10,
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.access_time,
                        size: 10, color: AppTheme.textTertiary),
                    const SizedBox(width: 2),
                    Text(
                      AppConstants.formatDuration(topic.estimatedTimeHours),
                      style: const TextStyle(
                          fontSize: 10, color: AppTheme.textTertiary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
