import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joby/core/di/dependency_injection.dart';
import 'package:joby/core/routes/app_router.dart';
import 'package:joby/joby_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //
  await SystemChrome.setPreferredOrientations([.portraitUp]);
  //
  await initGetIt();
  //
  await ScreenUtil.ensureScreenSize();
  runApp(JobyApp(appRouter: AppRouter()));
}
