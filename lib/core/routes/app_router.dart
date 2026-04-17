import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:joby/core/routes/routes.dart';
import 'package:joby/features/common/on_boarding/presentation/screens/on_boarding_screen.dart';
import 'package:joby/features/common/on_boarding/manager/on_boarding_cubit.dart';
import 'package:joby/features/common/auth/presentation/screens/auth_screen.dart';
import 'package:joby/features/common/auth/manager/auth_cubit.dart';
import 'package:joby/core/di/dependency_injection.dart';
import 'package:joby/features/company/home/company_home_screen.dart';
import 'package:joby/features/users/about_us/presentation/screens/about_us_screen.dart';
import 'package:joby/features/users/advice/presentation/screens/advice_screen.dart';

import '../../features/users/edit_profile/manager/edit_profile_cubit.dart';
import '../../features/users/edit_profile/presentation/screens/edit_profile_screen.dart';
import '../../features/users/home/manager/user_home_cubit.dart';
import '../../features/users/root/screens/user_root_screen.dart';
import '../../features/users/user_info/manager/user_info_cubit.dart';
import '../../features/users/user_info/presentation/screens/user_info_screen.dart';

class AppRouter {
  Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      /// OnBoarding Screen
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

      /// User Info Screen
      case Routes.userInfoScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<UserInfoCubit>(
            create: (context) => getIt<UserInfoCubit>(),
            child: const UserInfoScreen(),
          ),
        );

      /// User Root Screen
      case Routes.userRootScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<UserHomeCubit>(
            create: (context) => getIt<UserHomeCubit>(),
            child: const UserRootScreen(),
          ),
        );

      /// Company Home Screen
      case Routes.companyHomeScreen:
        return MaterialPageRoute(builder: (_) => const CompanyHomeScreen());

      /// Edit Profile Screen
      case Routes.editProfileScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => getIt<EditProfileCubit>(),
            child: const EditProfileScreen(),
          ),
        );

      /// About Us Screen (static — no cubit needed)
      case Routes.aboutUsScreen:
        return MaterialPageRoute(builder: (_) => const AboutUsScreen());

      /// Advice / Feedback Screen (stateful — no cubit needed)
      case Routes.adviceScreen:
        return MaterialPageRoute(builder: (_) => const AdviceScreen());
    }
    return null;
  }
}
