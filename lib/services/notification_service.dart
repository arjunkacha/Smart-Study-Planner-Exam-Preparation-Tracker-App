import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/schedule_model.dart';

/// Service handling local notifications for study reminders
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  /// Initialize notification plugin
  static Future<void> init() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        // Handle notification tap
      },
    );

    _isInitialized = true;
  }

  /// Request permissions (Android 13+)
  static Future<void> requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// Show an immediate notification
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'study_planner_channel',
      'Study Planner',
      channelDescription: 'Notifications for study sessions and reminders',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
        android: androidDetails, iOS: iosDetails);

    await _plugin.show(id, title, body, details, payload: payload);
  }

  /// Schedule a notification for a study session
  static Future<void> scheduleSessionNotification(
      ScheduleModel schedule, String subjectName, String topicName) async {
    // Notify 15 minutes before session
    final notifyTime = schedule.scheduledDateTime
        .subtract(const Duration(minutes: 15));
    if (notifyTime.isBefore(DateTime.now())) return;

    const androidDetails = AndroidNotificationDetails(
      'study_sessions_channel',
      'Study Sessions',
      channelDescription: 'Reminders for upcoming study sessions',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
        android: androidDetails, iOS: iosDetails);

    await _plugin.zonedSchedule(
      schedule.id.hashCode,
      '📚 Study Session in 15 minutes!',
      '$topicName - $subjectName',
      tz.TZDateTime.from(notifyTime, tz.local),
      details,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Schedule daily reminder notification
  static Future<void> scheduleDailyReminder(String time) async {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final now = DateTime.now();
    var scheduledDate =
        DateTime(now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'daily_reminder_channel',
      'Daily Reminder',
      channelDescription: 'Daily study reminder',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
        android: androidDetails, iOS: iosDetails);

    await _plugin.zonedSchedule(
      999,
      '📖 Time to Study!',
      'Keep up your study streak - you got this!',
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Cancel a specific notification
  static Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  /// Cancel all notifications
  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
