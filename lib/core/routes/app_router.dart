import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:joby/core/routes/routes.dart';
import 'package:joby/features/common/on_boarding/presentation/screens/on_boarding_screen.dart';
import 'package:joby/features/common/on_boarding/manager/on_boarding_cubit.dart';
import 'package:joby/features/common/auth/presentation/screens/auth_screen.dart';
import 'package:joby/features/common/auth/manager/auth_cubit.dart';
import 'package:joby/core/di/dependency_injection.dart';

class AppRouter {
  Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      /// onBoardingScreen
      case Routes.onBoardingScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<OnBoardingCubit>(
            create: (context) => getIt<OnBoardingCubit>(),
            child: const OnBoardingScreen(),
          ),
        );

      /// Auth Screen
      case Routes.authScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<AuthCubit>(
            create: (context) => getIt<AuthCubit>(),
            child: const AuthScreen(),
          ),
        );
    }
    return null;
  }
}
