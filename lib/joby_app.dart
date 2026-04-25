import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joby/core/routes/app_router.dart';
import 'package:joby/core/widgets/offline_mode_widget.dart';

class JobyApp extends StatelessWidget {
  const JobyApp({
    super.key,
    required this.appRouter,
    required this.initialRoute,
  });
  final AppRouter appRouter;
  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      //
      designSize: const Size(366, 815),
      minTextAdapt: true,
      splitScreenMode: true,
      //
      builder: (context, child) => GestureDetector(
        //
        onTap: () => FocusScope.of(context).unfocus(),
        //
        child: MaterialApp(
          //
          theme: ThemeData(useMaterial3: true, fontFamily: "Poppins"),
          //
          initialRoute: initialRoute,
          onGenerateRoute: appRouter.generateRoute,
          //
          debugShowCheckedModeBanner: false,
          //
          // Global offline overlay — covers every screen in the app
          builder: (context, child) {
            return OfflineBuilder(
              connectivityBuilder: (context, value, offlineChild) {
                final bool isConnected = !value.contains(
                  ConnectivityResult.none,
                );
                return Stack(
                  children: [
                    // Current screen (always rendered underneath)
                    child!,
                    //
                    // Full-screen offline overlay
                    if (!isConnected) OfflineModeWidget(),
                    //
                  ],
                );
              },
              child: const SizedBox.shrink(),
            );
          },
          //
        ),
      ),
    );
  }
}
