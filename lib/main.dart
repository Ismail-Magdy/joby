import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";
import "package:joby/core/di/dependency_injection.dart";
import "package:joby/core/helpers/constants.dart";
import "package:joby/core/helpers/shared_prefrences_helper.dart";
import "package:joby/core/routes/app_router.dart";
import "package:joby/core/routes/routes.dart";
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

  // Determine initial route from session state
  String initialRoute = Routes.onBoardingScreen;

  final session = Supabase.instance.client.auth.currentSession;
  if (session != null) {
    final userType = await SharedPrefHelper.getString(AppConstants.userTypeKey);

    if (userType == "company") {
      initialRoute = Routes.companyHomeScreen;
    } else {
      final isInfoCompleted = await SharedPrefHelper.getBool(
        AppConstants.isUserInfoCompletedKey,
      );

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

// ismailmagdy021@gmail.com
// ismailmagdy861@gmail.com
// ismailmagdy070@gmail.com
// Google
// ismailmagdy960@gmail.com
