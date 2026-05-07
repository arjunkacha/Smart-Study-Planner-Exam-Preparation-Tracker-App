import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Utility constants and helpers used throughout the app
class AppConstants {
  AppConstants._();

  static const String appName = 'Smart Study Planner';
  static const String appVersion = '1.0.0';

  /// Subject icon options
  static const List<Map<String, dynamic>> subjectIcons = [
    {'name': 'math', 'icon': Icons.calculate_outlined},
    {'name': 'science', 'icon': Icons.science_outlined},
    {'name': 'language', 'icon': Icons.language_outlined},
    {'name': 'history', 'icon': Icons.history_edu_outlined},
    {'name': 'art', 'icon': Icons.palette_outlined},
    {'name': 'music', 'icon': Icons.music_note_outlined},
    {'name': 'sports', 'icon': Icons.sports_outlined},
    {'name': 'computer', 'icon': Icons.computer_outlined},
    {'name': 'book', 'icon': Icons.menu_book_outlined},
    {'name': 'flask', 'icon': Icons.biotech_outlined},
    {'name': 'geography', 'icon': Icons.public_outlined},
    {'name': 'economics', 'icon': Icons.bar_chart_outlined},
  ];

  /// Get icon data from name string
  static IconData getIconData(String name) {
    return subjectIcons
        .firstWhere(
          (e) => e['name'] == name,
          orElse: () => {'icon': Icons.menu_book_outlined},
        )['icon'] as IconData;
  }

  /// Get color from int value
  static Color colorFromValue(int value) => Color(value);

  /// Format duration in hours to human-readable string
  static String formatDuration(double hours) {
    if (hours < 1) {
      return '${(hours * 60).round()}m';
    }
    final h = hours.floor();
    final m = ((hours - h) * 60).round();
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  /// Format a DateTime to "Mon, 12 May"
  static String formatDate(DateTime date) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    const days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
  }

  /// Format time string "HH:mm" to 12-hour format "10:30 AM"
  static String formatTime(String time24) {
    final parts = time24.split(':');
    int hour = int.parse(parts[0]);
    final minute = parts[1];
    final period = hour >= 12 ? 'PM' : 'AM';
    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;
    return '$hour:$minute $period';
  }

  /// Get status color
  static Color statusColor(String status) {
    switch (status) {
      case 'Completed':
        return AppTheme.success;
      case 'In Progress':
        return AppTheme.warning;
      default:
        return AppTheme.textTertiary;
    }
  }

  /// Days of the week abbreviated
  static const List<String> weekDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
}
