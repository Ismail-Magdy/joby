import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as timezone;
import 'package:timezone/timezone.dart' as timezone;

class LocalNotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    timezone.initializeTimeZones();
    timezone.setLocalLocation(timezone.getLocation("Africa/Cairo"));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings("@mipmap/ic_launcher");

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await flutterLocalNotificationsPlugin.initialize(
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap navigation
      },
      settings: initializationSettings,
    );
  }

  Future<void> requestPermissions() async {
    if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } else if (Platform.isAndroid) {
      final androidImplementation = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      await androidImplementation?.requestNotificationsPermission();
      await androidImplementation?.requestExactAlarmsPermission();
    }
  }

  Future<void> scheduleDailyCheckInReminder() async {
    final timezone.TZDateTime now = timezone.TZDateTime.now(timezone.local);

    timezone.TZDateTime scheduledDate = timezone.TZDateTime(
      timezone.local,
      now.year,
      now.month,
      now.day,
      14,
      0,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: 1,
      title: "We Miss You Today",
      body: "Come in Now and Collect Your 10 points Before They\"re Gone",
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          "daily_check_in_channel",
          "Daily Check-in",
          channelDescription: "Reminders for daily check-in points",
          importance: .max,
          priority: .high,
          icon: "@mipmap/ic_launcher",
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: .exactAllowWhileIdle,
      matchDateTimeComponents: .time,
    );
  }

  Future<void> scheduleProfileViewsReminder() async {
    final timezone.TZDateTime now = timezone.TZDateTime.now(timezone.local);

    timezone.TZDateTime scheduledDate = timezone.TZDateTime(
      timezone.local,
      now.year,
      now.month,
      now.day,
      20,
      0,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: 2,
      title: "Great News",
      body:
          "Did any Company See Your CV Today? Check Out Who Viewed Your Profile",
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          "profile_views_channel",
          "Profile Views",
          channelDescription: "Reminders to check profile views",
          importance: .max,
          priority: .high,
          icon: "@mipmap/ic_launcher",
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: .exactAllowWhileIdle,
      matchDateTimeComponents: .time,
    );
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id: id);
  }
}
