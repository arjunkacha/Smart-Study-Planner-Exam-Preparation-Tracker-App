import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Settings state
class SettingsState {
  final bool isDarkMode;
  final bool notificationsEnabled;
  final bool dailyReminderEnabled;
  final String dailyReminderTime; // "HH:mm"
  final DateTime? lastSyncTime;

  const SettingsState({
    this.isDarkMode = false,
    this.notificationsEnabled = true,
    this.dailyReminderEnabled = true,
    this.dailyReminderTime = '08:00',
    this.lastSyncTime,
  });

  SettingsState copyWith({
    bool? isDarkMode,
    bool? notificationsEnabled,
    bool? dailyReminderEnabled,
    String? dailyReminderTime,
    DateTime? lastSyncTime,
  }) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      dailyReminderEnabled: dailyReminderEnabled ?? this.dailyReminderEnabled,
      dailyReminderTime: dailyReminderTime ?? this.dailyReminderTime,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }
}

/// Notifier for app settings
class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState()) {
    _loadSettings();
  }

  SharedPreferences? _prefs;

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    state = SettingsState(
      isDarkMode: _prefs!.getBool('isDarkMode') ?? false,
      notificationsEnabled: _prefs!.getBool('notificationsEnabled') ?? true,
      dailyReminderEnabled: _prefs!.getBool('dailyReminderEnabled') ?? true,
      dailyReminderTime: _prefs!.getString('dailyReminderTime') ?? '08:00',
      lastSyncTime: _prefs!.getString('lastSyncTime') != null
          ? DateTime.tryParse(_prefs!.getString('lastSyncTime')!)
          : null,
    );
  }

  Future<void> toggleDarkMode() async {
    state = state.copyWith(isDarkMode: !state.isDarkMode);
    await _prefs?.setBool('isDarkMode', state.isDarkMode);
  }

  Future<void> toggleNotifications() async {
    state = state.copyWith(notificationsEnabled: !state.notificationsEnabled);
    await _prefs?.setBool('notificationsEnabled', state.notificationsEnabled);
  }

  Future<void> toggleDailyReminder() async {
    state = state.copyWith(dailyReminderEnabled: !state.dailyReminderEnabled);
    await _prefs?.setBool('dailyReminderEnabled', state.dailyReminderEnabled);
  }

  Future<void> setDailyReminderTime(String time) async {
    state = state.copyWith(dailyReminderTime: time);
    await _prefs?.setString('dailyReminderTime', time);
  }

  Future<void> updateLastSyncTime() async {
    final now = DateTime.now();
    state = state.copyWith(lastSyncTime: now);
    await _prefs?.setString('lastSyncTime', now.toIso8601String());
  }
}

/// Settings provider
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});
