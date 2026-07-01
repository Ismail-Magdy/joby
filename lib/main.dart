import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";
import "package:joby/core/di/dependency_injection.dart";
import "package:joby/core/helpers/constants.dart";
import "package:joby/core/helpers/shared_prefrences_helper.dart";
import "package:joby/core/routes/app_router.dart";
import "package:joby/core/routes/routes.dart";
import "package:joby/features/users/notification/data/services/local_notification_service.dart";
import "package:joby/joby_app.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([.portraitUp]);

  // Load Environment Variables
  await dotenv.load(fileName: ".env");

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env["SUPABASE_URL"]!,
    anonKey: dotenv.env["SUPABASE_ANON_KEY"]!,
  );

  // Initialize GetIt service locator
  await initGetIt();

  // Initialize Local Notifications (init & permissions for all user types)
  final notificationService = getIt<LocalNotificationService>();
  await notificationService.init();
  await notificationService.requestPermissions();

  // Determine initial route from session state
  String initialRoute = Routes.onBoardingScreen;

  final session = Supabase.instance.client.auth.currentSession;
  if (session != null) {
    final userType = await SharedPrefHelper.getString(AppConstants.userTypeKey);

    if (userType == "company") {
      // Cancel any previously scheduled user-specific notifications
      await notificationService.cancelNotification(1);
      await notificationService.cancelNotification(2);

      bool isCompanyInfoCompleted = false;
      try {
        final managerData = await Supabase.instance.client
            .from("managers_data")
            .select("manager_id")
            .eq("manager_id", session.user.id)
            .maybeSingle();

        if (managerData != null) {
          isCompanyInfoCompleted = true;
          // Sync shared preferences just in case
          await SharedPrefHelper.setData(
            AppConstants.isCompanyInfoCompletedKey,
            true,
          );
        }
      } catch (_) {
        // Fallback to shared preferences if network error
        isCompanyInfoCompleted = await SharedPrefHelper.getBool(
          AppConstants.isCompanyInfoCompletedKey,
        );
      }

      if (isCompanyInfoCompleted == true) {
        initialRoute = Routes.companyRootScreen;
      } else {
        initialRoute = Routes.companyInfoScreen;
      }
    } else {
      // Schedule notifications only for regular users (job seekers)
      await notificationService.scheduleDailyCheckInReminder();
      await notificationService.scheduleProfileViewsReminder();

      bool isInfoCompleted = false;
      try {
        final userData = await Supabase.instance.client
            .from("users")
            .select("id, name")
            .eq("id", session.user.id)
            .maybeSingle();

        if (userData != null && userData["name"] != null) {
          isInfoCompleted = true;
          // Sync shared preferences
          await SharedPrefHelper.setData(
            AppConstants.isUserInfoCompletedKey,
            true,
          );
        }
      } catch (_) {
        // Fallback to shared preferences if network error
        isInfoCompleted = await SharedPrefHelper.getBool(
          AppConstants.isUserInfoCompletedKey,
        );
      }

      if (isInfoCompleted == true) {
        initialRoute = Routes.userRootScreen;
      } else {
        initialRoute = Routes.userInfoScreen;
      }
    }
  }

  await ScreenUtil.ensureScreenSize();

  runApp(JobyApp(appRouter: AppRouter(), initialRoute: initialRoute));
}
