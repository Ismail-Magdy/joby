import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joby/core/routes/app_router.dart';
import 'package:joby/core/routes/routes.dart';

class JobyApp extends StatelessWidget {
  const JobyApp({super.key, required this.appRouter});
  final AppRouter appRouter;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(366, 815),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: MaterialApp(
          theme: ThemeData(useMaterial3: true, fontFamily: "BrunoAceSC"),
          onGenerateRoute: appRouter.generateRoute,
          initialRoute: Routes.onBoardingScreen,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
