import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/settings_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/subject_provider.dart';
import '../../providers/topic_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../providers/connectivity_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_constants.dart';

/// Settings screen with theme toggle, notifications, backup and sync
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isOnline = ref.watch(isOnlineProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // App header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF6C63FF), Color(0xFF3D35CC)],
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.school_rounded,
                      color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      AppConstants.appName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'v${AppConstants.appVersion}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Appearance
          _SectionHeader(title: 'Appearance'),
          _SettingsTile(
            icon: settings.isDarkMode
                ? Icons.dark_mode_rounded
                : Icons.light_mode_rounded,
            iconColor: settings.isDarkMode
                ? const Color(0xFF6C63FF)
                : const Color(0xFFF59E0B),
            title: 'Dark Mode',
            subtitle: settings.isDarkMode ? 'Dark theme active' : 'Light theme active',
            trailing: Switch(
              value: settings.isDarkMode,
              activeColor: AppTheme.primary,
              onChanged: (_) =>
                  ref.read(settingsProvider.notifier).toggleDarkMode(),
            ),
          ),

          // Notifications
          _SectionHeader(title: 'Notifications'),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            iconColor: AppTheme.info,
            title: 'Push Notifications',
            subtitle: 'Enable all notifications',
            trailing: Switch(
              value: settings.notificationsEnabled,
              activeColor: AppTheme.primary,
              onChanged: (_) =>
                  ref.read(settingsProvider.notifier).toggleNotifications(),
            ),
          ),
          _SettingsTile(
            icon: Icons.alarm_outlined,
            iconColor: AppTheme.secondary,
            title: 'Daily Reminder',
            subtitle: 'Remind to study every day',
            trailing: Switch(
              value: settings.dailyReminderEnabled,
              activeColor: AppTheme.primary,
              onChanged: settings.notificationsEnabled
                  ? (_) => ref
                      .read(settingsProvider.notifier)
                      .toggleDailyReminder()
                  : null,
            ),
          ),
          if (settings.dailyReminderEnabled && settings.notificationsEnabled)
            _SettingsTile(
              icon: Icons.schedule_outlined,
              iconColor: AppTheme.warning,
              title: 'Reminder Time',
              subtitle: AppConstants.formatTime(settings.dailyReminderTime),
              trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
              onTap: () => _pickReminderTime(context, ref, settings),
            ),

          // Sync & Backup
          _SectionHeader(title: 'Sync & Backup'),
          _SettingsTile(
            icon: isOnline ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
            iconColor: isOnline ? AppTheme.success : AppTheme.textTertiary,
            title: 'Sync Status',
            subtitle: isOnline ? 'Online - Data will sync' : 'Offline Mode',
            trailing: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isOnline ? AppTheme.success : AppTheme.warning,
                shape: BoxShape.circle,
              ),
            ),
          ),
          if (settings.lastSyncTime != null)
            _SettingsTile(
              icon: Icons.history_rounded,
              iconColor: AppTheme.textSecondary,
              title: 'Last Synced',
              subtitle: _formatDateTime(settings.lastSyncTime!),
            ),
          _SettingsTile(
            icon: Icons.sync_rounded,
            iconColor: AppTheme.primary,
            title: 'Sync Now',
            subtitle: isOnline
                ? 'Sync your data to cloud'
                : 'Not available offline',
            trailing: const Icon(Icons.chevron_right,
                color: AppTheme.textSecondary),
            onTap: isOnline
                ? () {
                    ref
                        .read(settingsProvider.notifier)
                        .updateLastSyncTime();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Data synced successfully!'),
                        backgroundColor: AppTheme.success,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                : null,
          ),

          // Data
          _SectionHeader(title: 'Data'),
          _SettingsTile(
            icon: Icons.download_outlined,
            iconColor: AppTheme.info,
            title: 'Export Data',
            subtitle: 'Export all data as JSON',
            trailing: const Icon(Icons.chevron_right,
                color: AppTheme.textSecondary),
            onTap: () => _exportData(context, ref),
          ),
          _SettingsTile(
            icon: Icons.delete_outline_rounded,
            iconColor: AppTheme.error,
            title: 'Clear All Data',
            subtitle: 'Delete all subjects, topics, and sessions',
            trailing: const Icon(Icons.chevron_right,
                color: AppTheme.textSecondary),
            onTap: () => _confirmClearData(context, ref),
          ),

          // About
          _SectionHeader(title: 'About'),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            iconColor: AppTheme.primary,
            title: 'Version',
            subtitle: AppConstants.appVersion,
          ),
          _SettingsTile(
            icon: Icons.code_rounded,
            iconColor: AppTheme.secondary,
            title: 'Tech Stack',
            subtitle: 'Flutter • Riverpod • Hive',
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _pickReminderTime(
      BuildContext context, WidgetRef ref, SettingsState settings) async {
    final parts = settings.dailyReminderTime.split(':');
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
          hour: int.parse(parts[0]), minute: int.parse(parts[1])),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      final h = picked.hour.toString().padLeft(2, '0');
      final m = picked.minute.toString().padLeft(2, '0');
      ref.read(settingsProvider.notifier).setDailyReminderTime('$h:$m');
    }
  }

  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    final db = ref.read(databaseServiceProvider);
    final data = db.exportData();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Exported ${data['subjects'].length} subjects, ${data['topics'].length} topics, ${data['schedules'].length} schedules'),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _confirmClearData(BuildContext context, WidgetRef ref) async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear All Data?'),
        content: const Text(
            'This will permanently delete ALL your subjects, topics, and sessions. This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () async {
              Navigator.pop(context);
              final db = ref.read(databaseServiceProvider);
              await db.clearAll();
              ref.read(subjectProvider.notifier).refresh();
              ref.read(topicProvider.notifier).refresh();
              ref.read(scheduleProvider.notifier).refresh();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All data cleared'),
                    backgroundColor: AppTheme.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppTheme.textSecondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color:
              isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: isDark
              ? AppTheme.darkTextSecondary
              : AppTheme.textSecondary,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
