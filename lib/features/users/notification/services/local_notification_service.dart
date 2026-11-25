import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:joby/core/helpers/constants.dart';
import 'package:joby/features/users/user_info/data/models/user_info_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest_all.dart' as timezone;
import 'package:timezone/timezone.dart' as timezone;

class LocalNotificationService {
  final SharedPreferences sharedPrefs;
  final SupabaseClient supabaseClient;

  LocalNotificationService({
    required this.sharedPrefs,
    required this.supabaseClient,
  });

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // Notification IDs
  static const int dailyCheckInId = 101;
  static const int dailyMiniGamesId = 102;
  static const int profileViewsId = 103;
  static const int streakSaverId = 104;
  static const int incompleteProfileId = 105;
  static const int weeklyFreshnessId = 106;

  // SharedPreferences Keys
  static const String lastCelebrationDateKey = 'last_celebration_date';
  static const String dailyStreakCountKey = 'joby_daily_streak_count';
  static const String dailyStreakLastDateKey = 'joby_daily_streak_last_date';
  static const String _gamePrefPrefix = 'joby_game_last_played_';
  static const List<String> _gameIds = [
    'spin_wheel',
    'catch_logo',
    'memory_match',
    'logo_puzzle',
  ];

  /// Lazily initializes the notification plugin and local timezone.
  Future<void> init() async {
    if (_isInitialized) return;

    timezone.initializeTimeZones();
    timezone.setLocalLocation(timezone.getLocation('Africa/Cairo'));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

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

    _isInitialized = true;
  }

  /// Ensures the plugin is initialized before any schedule or cancel operation.
  Future<void> ensureInitialized() async {
    if (!_isInitialized) {
      await init();
    }
  }

  /// Strict role guard: notifications are exclusive to authenticated Job Seekers.
  bool get isJobSeeker {
    final session = supabaseClient.auth.currentSession;
    if (session == null) return false;

    final rawType =
        sharedPrefs.getString(AppConstants.userTypeKey)?.toLowerCase() ?? '';
    if (rawType.contains('company') || rawType.contains('business')) {
      return false;
    }
    return true;
  }

  /// Requests notification permissions exclusively for Job Seeker accounts.
  Future<void> requestPermissions() async {
    if (!isJobSeeker) return;
    await ensureInitialized();

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

  /// Cancels all scheduled notifications (e.g., on logout or Company session).
  Future<void> cancelAllNotifications() async {
    await ensureInitialized();
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Cancels a specific notification by [id].
  Future<void> cancelNotification(int id) async {
    await ensureInitialized();
    await flutterLocalNotificationsPlugin.cancel(id: id);
  }

  /// Centralized synchronization for all 6 smart Job Seeker notifications.
  ///
  /// Automatically cancels all notifications and exits early if the current
  /// session is logged out or belongs to a Company account.
  Future<void> syncUserNotifications({
    UserInfoModel? userInfo,
    bool requestPermissionIfNeeded = false,
  }) async {
    if (!isJobSeeker) {
      await cancelAllNotifications();
      return;
    }

    await ensureInitialized();
    if (requestPermissionIfNeeded) {
      await requestPermissions();
    }

    // Cancel legacy notification IDs from older builds if present
    await cancelNotification(1);
    await cancelNotification(2);

    final todayLocal = DateTime.now().toIso8601String().substring(0, 10);
    final hasClaimedToday =
        sharedPrefs.getString(lastCelebrationDateKey) == todayLocal ||
        userInfo?.lastCheckIn == todayLocal;

    final streak = _getCurrentStreak();
    final playedGamesCount = _getPlayedGamesTodayCount();
    final isProfileComplete = await _isProfileComplete(userInfo);

    await scheduleDailyCheckInReminder(hasClaimedToday: hasClaimedToday);
    await scheduleDailyMiniGamesReminder(playedGamesCount: playedGamesCount);
    await scheduleProfileViewsReminder();
    await scheduleStreakSaverReminder(
      streak: streak,
      hasClaimedToday: hasClaimedToday,
    );
    await scheduleIncompleteProfileReminder(
      isProfileComplete: isProfileComplete,
    );
    await scheduleWeeklyProfileFreshnessReminder();
  }

  /// Notification 1 (ID: 101): Daily Check-In Boost at 2:00 PM.
  /// If already claimed today, cancels today's trigger and schedules for tomorrow.
  Future<void> scheduleDailyCheckInReminder({
    bool hasClaimedToday = false,
  }) async {
    if (!isJobSeeker) return;
    await ensureInitialized();

    await cancelNotification(dailyCheckInId);

    final now = timezone.TZDateTime.now(timezone.local);
    var scheduledDate = timezone.TZDateTime(
      timezone.local,
      now.year,
      now.month,
      now.day,
      14,
      0,
    );

    if (hasClaimedToday || !scheduledDate.isAfter(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: dailyCheckInId,
      title: 'Daily Check In Reminder',
      body:
          'Open Joby Today To Claim Your 10 Daily Points And Keep Your Profile Active',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_check_in_channel',
          'Daily Check In',
          channelDescription: 'Reminders For Daily Check In Points',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Notification 2 (ID: 102): Daily Mini-Games Bonus at 5:30 PM.
  /// If all 4 games are already played today, schedules for tomorrow at 5:30 PM.
  Future<void> scheduleDailyMiniGamesReminder({
    required int playedGamesCount,
  }) async {
    if (!isJobSeeker) return;
    await ensureInitialized();

    await cancelNotification(dailyMiniGamesId);

    final now = timezone.TZDateTime.now(timezone.local);
    var scheduledDate = timezone.TZDateTime(
      timezone.local,
      now.year,
      now.month,
      now.day,
      17,
      30,
    );

    if (playedGamesCount >= 4 || !scheduledDate.isAfter(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: dailyMiniGamesId,
      title: 'Daily Mini Games Available',
      body:
          'Play Your 4 Daily Mini Games To Earn Bonus Points And Boost Your Profile Rank',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_mini_games_channel',
          'Daily Mini Games',
          channelDescription: 'Reminders For Daily Mini Games Bonus Points',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Notification 3 (ID: 103): Profile Views Check at 8:00 PM daily.
  Future<void> scheduleProfileViewsReminder() async {
    if (!isJobSeeker) return;
    await ensureInitialized();

    await cancelNotification(profileViewsId);

    final now = timezone.TZDateTime.now(timezone.local);
    var scheduledDate = timezone.TZDateTime(
      timezone.local,
      now.year,
      now.month,
      now.day,
      20,
      0,
    );

    if (!scheduledDate.isAfter(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: profileViewsId,
      title: 'Check Your Profile Views',
      body:
          'Did Any Companies View Your Profile Today? Tap To Check Your Recent Visitors',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'profile_views_channel',
          'Profile Views',
          channelDescription: 'Reminders To Check Profile Views',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Notification 4 (ID: 104): Streak Saver Warning at 10:30 PM.
  /// Scheduled for today only when streak >= 2 and today's points are unclaimed;
  /// if claimed today and streak > 0, scheduled for tomorrow at 10:30 PM.
  Future<void> scheduleStreakSaverReminder({
    required int streak,
    required bool hasClaimedToday,
  }) async {
    if (!isJobSeeker) return;
    await ensureInitialized();

    await cancelNotification(streakSaverId);

    if (streak <= 0 || (!hasClaimedToday && streak < 2)) {
      return;
    }

    final now = timezone.TZDateTime.now(timezone.local);
    var scheduledDate = timezone.TZDateTime(
      timezone.local,
      now.year,
      now.month,
      now.day,
      22,
      30,
    );

    if (hasClaimedToday || !scheduledDate.isAfter(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: streakSaverId,
      title: 'Protect Your Daily Streak',
      body:
          'Only 90 Minutes Left To Claim Your Daily 10 Points Before Your Streak Resets',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'streak_saver_channel',
          'Streak Saver',
          channelDescription: 'Reminders To Protect Your Daily Streak',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: .exactAllowWhileIdle,
      matchDateTimeComponents: .time,
    );
  }

  /// Notification 5 (ID: 105): Incomplete Profile Nudge every 3 days at 12:00 PM.
  /// Permanently cancelled once the Job Seeker profile is 100% complete.
  Future<void> scheduleIncompleteProfileReminder({
    required bool isProfileComplete,
  }) async {
    if (!isJobSeeker) return;
    await ensureInitialized();

    await cancelNotification(incompleteProfileId);

    if (isProfileComplete) {
      return;
    }

    final now = timezone.TZDateTime.now(timezone.local);
    final scheduledDate = timezone.TZDateTime(
      timezone.local,
      now.year,
      now.month,
      now.day,
      12,
      0,
    ).add(const Duration(days: 3));

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: incompleteProfileId,
      title: 'Complete Your Joby Profile',
      body:
          'Upload Your Resume And Complete Your Details To Appear Higher In Recruiter Searches',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'incomplete_profile_channel',
          'Incomplete Profile',
          channelDescription: 'Reminders To Complete Your Joby Profile',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Notification 6 (ID: 106): Weekly Profile Freshness Reminder on Sunday at 11:00 AM.
  Future<void> scheduleWeeklyProfileFreshnessReminder() async {
    if (!isJobSeeker) return;
    await ensureInitialized();

    await cancelNotification(weeklyFreshnessId);

    final now = timezone.TZDateTime.now(timezone.local);
    var scheduledDate = timezone.TZDateTime(
      timezone.local,
      now.year,
      now.month,
      now.day,
      11,
      0,
    );

    final daysUntilSunday = (DateTime.sunday - scheduledDate.weekday) % 7;
    scheduledDate = scheduledDate.add(Duration(days: daysUntilSunday));
    if (!scheduledDate.isAfter(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: weeklyFreshnessId,
      title: 'New Week Career Opportunities',
      body:
          'Explore Hiring Companies On Joby And Keep Your Profile Updated For Recruiters',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'weekly_freshness_channel',
          'Weekly Opportunities',
          channelDescription: 'Weekly Career And Profile Freshness Reminders',
          importance: .defaultImportance,
          priority: .defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: .exactAllowWhileIdle,
      matchDateTimeComponents: .dayOfWeekAndTime,
    );
  }

  int _getCurrentStreak() {
    final lastDateStr = sharedPrefs.getString(dailyStreakLastDateKey);
    final savedCount = sharedPrefs.getInt(dailyStreakCountKey) ?? 0;
    if (lastDateStr == null || savedCount <= 0) return 0;

    final lastDate = DateTime.tryParse(lastDateStr);
    if (lastDate == null) return 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDay = DateTime(lastDate.year, lastDate.month, lastDate.day);
    final diffDays = today.difference(lastDay).inDays;

    // Streak remains active if last check-in was today or yesterday
    if (diffDays <= 1) {
      return savedCount;
    }
    return 0;
  }

  int _getPlayedGamesTodayCount() {
    final now = DateTime.now();
    int played = 0;
    for (final gameId in _gameIds) {
      final lastPlayedStr = sharedPrefs.getString('$_gamePrefPrefix$gameId');
      if (lastPlayedStr == null) continue;
      final lastPlayed = DateTime.tryParse(lastPlayedStr);
      if (lastPlayed != null &&
          now.difference(lastPlayed) < const Duration(hours: 18)) {
        played++;
      }
    }
    return played;
  }

  Future<bool> _isProfileComplete(UserInfoModel? userInfo) async {
    UserInfoModel? profile = userInfo;
    if (profile == null) {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) return false;
      try {
        final data = await supabaseClient
            .from(AppConstants.usersTable)
            .select()
            .eq('id', userId)
            .maybeSingle();
        if (data == null) return false;
        profile = UserInfoModel.fromJson(data);
      } catch (_) {
        // Avoid cancelling completeness reminder on transient network errors
        return false;
      }
    }

    final hasCv = profile.cvUrl != null && profile.cvUrl!.trim().isNotEmpty;
    final hasAvatar =
        profile.avatarUrl != null && profile.avatarUrl!.trim().isNotEmpty;
    final hasLocation =
        profile.locationName.trim().isNotEmpty &&
        profile.locationName != 'Unknown Location' &&
        profile.latitude != 0.0 &&
        profile.longitude != 0.0;
    final hasAnySocialLink =
        (profile.linkedin != null && profile.linkedin!.trim().isNotEmpty) ||
        (profile.github != null && profile.github!.trim().isNotEmpty) ||
        (profile.behance != null && profile.behance!.trim().isNotEmpty);

    return hasCv && hasAvatar && hasLocation && hasAnySocialLink;
  }
}
