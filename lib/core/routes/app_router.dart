import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:joby/core/routes/routes.dart';
import 'package:joby/core/widgets/exit_confirmation_wrapper.dart';
import 'package:joby/core/di/dependency_injection.dart';
import 'package:joby/features/common/on_boarding/presentation/screens/on_boarding_screen.dart';
import 'package:joby/features/common/on_boarding/manager/on_boarding_cubit.dart';
import 'package:joby/features/common/auth/presentation/screens/auth_screen.dart';
import 'package:joby/features/common/auth/manager/auth_cubit.dart';
import 'package:joby/features/company/company_info/manager/company_info_cubit.dart';
import 'package:joby/features/company/company_info/presentation/screens/company_info_screen.dart';
import 'package:joby/features/company/home/manager/company_home_cubit.dart';
import 'package:joby/features/company/home/presentation/screens/company_home_screen.dart';
import 'package:joby/features/company/profile_company/screens/company_profile_screen.dart';
import 'package:joby/features/company/root/screens/company_root_screen.dart';
import 'package:joby/features/common/about_us/screens/about_us_screen.dart';
import 'package:joby/features/common/feed_back/presentation/screens/feed_back_screen.dart';
import 'package:joby/features/users/home/presentation/screens/company_view_screen.dart';
import 'package:joby/features/users/profile_users/screens/users_profile_screen.dart.dart';
import 'package:joby/features/users/user_info/data/models/user_info_model.dart';
import '../../features/common/feed_back/manager/advice_cubit.dart';
import '../../features/users/edit_profile/manager/edit_profile_cubit.dart';
import '../../features/users/edit_profile/presentation/screens/edit_profile_screen.dart';
import '../../features/users/home/manager/user_home_cubit.dart';
import '../../features/users/root/screens/user_root_screen.dart';
import '../../features/users/user_info/manager/user_info_cubit.dart';
import '../../features/users/user_info/presentation/screens/user_info_screen.dart';
import '../../features/users/points/manager/points_cubit.dart';
import '../../features/users/points/presentation/screens/points_screen.dart';

class AppRouter {
  Route? generateRoute(RouteSettings settings) {
    // Intercept Supabase Email Verification Deep Links
    if (settings.name != null &&
        (settings.name!.contains("code=") ||
            settings.name!.contains("login-callback"))) {
      return MaterialPageRoute(
        builder: (_) => BlocProvider<AuthCubit>(
          create: (context) => getIt<AuthCubit>(),
          child: const AuthScreen(isDeepLink: true),
        ),
      );
    }
    //

    switch (settings.name) {
      //// Job Seeker Part

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
          builder: (_) => ExitConfirmationWrapper(
            child: BlocProvider<UserInfoCubit>(
              create: (context) => getIt<UserInfoCubit>(),
              child: const UserInfoScreen(),
            ),
          ),
        );

      /// User Root Screen
      case Routes.userRootScreen:
        return MaterialPageRoute(
          builder: (_) => ExitConfirmationWrapper(
            child: MultiBlocProvider(
              providers: [
                BlocProvider<UserHomeCubit>(
                  create: (context) => getIt<UserHomeCubit>(),
                ),
                BlocProvider<PointsCubit>(
                  create: (context) => getIt<PointsCubit>(),
                ),
              ],
              child: const UserRootScreen(),
            ),
          ),
        );

      /// Edit Profile Screen
      case Routes.editProfileScreen:
        final userInfo = settings.arguments as UserInfoModel?;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => getIt<EditProfileCubit>(),
            child: EditProfileScreen(currentUserInfo: userInfo),
          ),
        );

      /// About Us Screen
      case Routes.aboutUsScreen:
        return MaterialPageRoute(builder: (_) => const AboutUsScreen());

      /// Users Profile Screen
      case Routes.usersProfileScreen:
        return MaterialPageRoute(builder: (_) => const UsersProfileScreen());

      /// Advice / Feedback Screen
      case Routes.feedBackScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<AdviceCubit>(
            create: (context) => getIt<AdviceCubit>(),
            child: const FeedBackScreen(),
          ),
        );

      /// Points Screen
      case Routes.pointsScreen:
        return MaterialPageRoute(builder: (_) => const PointsScreen());

      //// Company Part

      /// Company Info Screen
      case Routes.companyInfoScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<CompanyInfoCubit>(
            create: (context) => getIt<CompanyInfoCubit>(),
            child: const CompanyInfoScreen(),
          ),
        );

      /// Company Home Screen
      case Routes.companyHomeScreen:
        return MaterialPageRoute(
          builder: (_) =>
              const ExitConfirmationWrapper(child: CompanyHomeScreen()),
        );

      /// Company Root Screen
      case Routes.companyRootScreen:
        return MaterialPageRoute(
          builder: (_) => ExitConfirmationWrapper(
            child: MultiBlocProvider(
              providers: [
                BlocProvider<CompanyHomeCubit>(
                  create: (context) => getIt<CompanyHomeCubit>(),
                ),
              ],
              child: const CompanyRootScreen(),
            ),
          ),
        );

      /// Company Profile Screen
      case Routes.companyProfileScreen:
        return MaterialPageRoute(builder: (_) => const CompanyProfileScreen());

      /// Company Vieew Screen
      case Routes.companyViewScreen:
        return MaterialPageRoute(builder: (_) => const CompanyViewScreen());

      /// Default Case
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text("No Page Found For This ${settings.name}"),
            ),
          ),
        );
    }
  }
}
