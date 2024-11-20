import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initializeNotifications() async {
    tz.initializeTimeZones();
    const androidSetting = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSetting =
        InitializationSettings(android: androidSetting);
    await _notificationsPlugin.initialize(initializationSetting);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'reminder_channel',
      'Reminders',
      description: 'Channel for Reminder Notification',
      importance: Importance.high,
      playSound: true,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static Future<void> scheduleNotificaton(
      int id, String title, String category, DateTime scheduledTime) async {
    const androidDetail = AndroidNotificationDetails(
      'reminder_channel',
      'Reminders',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );
    final notificationDetails = NotificationDetails(android: androidDetail);
    if (scheduledTime.isBefore(DateTime.now())) {
    } else {
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        category,
        tz.TZDateTime.from(scheduledTime, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }
  static Future<void> cancelNotification(int id) async{
    await _notificationsPlugin.cancel(id);
  }
}
