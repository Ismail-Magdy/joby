import "package:flutter/material.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";
import "package:flutter_svg/svg.dart";
import "package:joby/core/di/dependency_injection.dart";
import "package:joby/core/widgets/exit_confirmation_wrapper.dart";
import "package:joby/core/widgets/joby_pixel_buddy.dart";
import "package:joby/features/users/home/presentation/screens/user_home_screen.dart";
import "package:joby/features/users/notification/services/local_notification_service.dart";
import "package:joby/features/users/points/presentation/screens/points_screen.dart";
import "package:joby/features/users/settings_users/presentation/screens/settings_users_screen.dart.dart";
import "package:joby/features/users/profile_views/presentation/screens/profile_views_screen.dart";
import "../../../../core/helpers/spacing.dart";
import "../../../../core/themes/app_colors.dart";

class UserRootScreen extends StatefulWidget {
  const UserRootScreen({super.key});

  @override
  State<UserRootScreen> createState() => _UserRootScreenState();
}

class _UserRootScreenState extends State<UserRootScreen> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    getIt<LocalNotificationService>().syncUserNotifications(
      requestPermissionIfNeeded: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExitConfirmationWrapper(
      child: Scaffold(
        extendBody: true,
        //
        body: Stack(
          children: [
            IndexedStack(
              index: currentIndex,
              children: [
                const UserHomeScreen(),
                const PointsScreen(),
                const ProfileViewsScreen(),
                const SettingsUsersScreen(),
              ],
            ),
            const JobyPixelBuddy(),
          ],
        ),
        //
        bottomNavigationBar: Padding(
          padding: .only(left: 20.w, right: 20.w, bottom: 20.h),
          child: SafeArea(
            top: false,
            bottom: true,
            child: Container(
              height: 68.h,
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: .circular(40.r),
              ),
              //
              child: Row(
                mainAxisAlignment: .spaceAround,
                children: [
                  //
                  _navItem(
                    index: 0,
                    icon: "assets/svgs/profile.svg",
                    title: "Profile",
                  ),
                  //
                  _navItem(
                    index: 1,
                    icon: "assets/svgs/points.svg",
                    title: "Points",
                  ),
                  //
                  _navItem(
                    index: 2,
                    icon: "assets/svgs/eye.svg",
                    title: "Views",
                  ),
                  //
                  _navItem(
                    index: 3,
                    icon: "assets/svgs/settings.svg",
                    title: "Settings",
                  ),
                  //
                ],
              ),
              //
            ),
          ),
        ),
        //
      ),
    );
  }

  Widget _navItem({
    required int index,
    required String icon,
    required String title,
  }) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => currentIndex = index),
      child: Column(
        mainAxisAlignment: .center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 50),
            curve: Curves.easeInOut,
            height: isSelected ? 38.h : 35.h,
            width: isSelected ? 38.w : 35.w,
            // Hover circle
            decoration: BoxDecoration(
              shape: .circle,
              color: isSelected
                  ? const Color(0xffB9E5E8).withValues(alpha: 0.4)
                  : Colors.transparent,
            ),
            // Icon
            child: Center(
              child: AnimatedScale(
                duration: const Duration(milliseconds: 50),
                scale: isSelected ? 1.1 : 1.0,
                child: SvgPicture.asset(
                  icon,
                  height: 20.h,
                  colorFilter: const .mode(Colors.white, .srcIn),
                ),
              ),
            ),
            //
          ),
          //
          verticalSpace(isSelected ? 2 : 2.5),
          //
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontFamily: "BrunoAceSC",
              color: Colors.white,
              fontSize: isSelected ? 11.sp : 10.sp,
              fontWeight: isSelected ? .bold : .normal,
            ),
            child: Text(title),
          ),
          //
        ],
      ),
    );
  }
}
