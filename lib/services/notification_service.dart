import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin
  flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static const int dailyReminderId = 1;

  static const String reminderHourKey = 'daily_reminder_hour';
  static const String reminderMinuteKey = 'daily_reminder_minute';
  static const String reminderEnabledKey = 'daily_reminder_enabled';

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
    InitializationSettings(
      android: androidSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'rupeelens_channel',
      'RupeeLens Notifications',
      channelDescription: 'Budget and Expense Alerts',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails details =
    NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      details,
    );
  }

  // Save user's selected reminder time
  static Future<void> saveReminderTime(
      int hour,
      int minute,
      ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(
      reminderHourKey,
      hour,
    );

    await prefs.setInt(
      reminderMinuteKey,
      minute,
    );
  }

  // Save reminder ON/OFF state
  static Future<void> setReminderEnabled(
      bool enabled,
      ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(
      reminderEnabledKey,
      enabled,
    );
  }

  // Get reminder ON/OFF state
  static Future<bool> isReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(
      reminderEnabledKey,
    ) ??
        false;
  }

  // Get saved reminder time
  static Future<({int hour, int minute})> getReminderTime() async {
    final prefs = await SharedPreferences.getInstance();

    final hour = prefs.getInt(
      reminderHourKey,
    ) ??
        20;

    final minute = prefs.getInt(
      reminderMinuteKey,
    ) ??
        0;

    return (
    hour: hour,
    minute: minute,
    );
  }

  // Schedule daily reminder using saved time
  static Future<void> scheduleDailyReminder() async {
    final reminderTime = await getReminderTime();

    final now = tz.TZDateTime.now(
      tz.local,
    );

    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      reminderTime.hour,
      reminderTime.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(
        const Duration(days: 1),
      );
    }

    await flutterLocalNotificationsPlugin.cancel(
      dailyReminderId,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      dailyReminderId,
      '💰 Daily Expense Reminder',
      "You haven't added today's expense yet.",
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'rupeelens_channel',
          'RupeeLens Notifications',
          channelDescription: 'Budget and Expense Alerts',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode:
      AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents:
      DateTimeComponents.time,
    );
  }

  // Called when today's expense has been added.
  // Cancels today's reminder and schedules the next day's reminder.
  static Future<void> markTodayExpenseAdded() async {
    await flutterLocalNotificationsPlugin.cancel(
      dailyReminderId,
    );

    await scheduleTomorrowReminder();
  }

  // Schedule reminder specifically for tomorrow
  static Future<void> scheduleTomorrowReminder() async {
    final reminderTime = await getReminderTime();

    final now = tz.TZDateTime.now(
      tz.local,
    );

    final tomorrow = now.add(
      const Duration(days: 1),
    );

    final scheduledDate = tz.TZDateTime(
      tz.local,
      tomorrow.year,
      tomorrow.month,
      tomorrow.day,
      reminderTime.hour,
      reminderTime.minute,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      dailyReminderId,
      '💰 Daily Expense Reminder',
      "You haven't added today's expense yet.",
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'rupeelens_channel',
          'RupeeLens Notifications',
          channelDescription: 'Budget and Expense Alerts',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode:
      AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents:
      DateTimeComponents.time,
    );
  }

  // Cancel reminder completely
  static Future<void> cancelDailyReminder() async {
    await flutterLocalNotificationsPlugin.cancel(
      dailyReminderId,
    );
  }
}