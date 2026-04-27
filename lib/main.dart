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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([.portraitUp]);

  // Initialize Supabase
  // ⚠️ TODO: Move URL and anonKey to flutter_dotenv or --dart-define before release
  await Supabase.initialize(
    url: "https://auoloqdhytirfnvazyft.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF1b2xvcWRoeXRpcmZudmF6eWZ0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM3NzcwMTIsImV4cCI6MjA4OTM1MzAxMn0.5EqbLv8XeRm65LA8KKpo5SwYGZ3nd5X49ZsX2rRHCc8",
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
