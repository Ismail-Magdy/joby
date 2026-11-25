import "package:flutter/material.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";
import "package:flutter_svg/svg.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:joby/core/di/dependency_injection.dart";
import "package:joby/core/helpers/spacing.dart";
import "package:joby/core/themes/app_colors.dart";
import "package:joby/core/widgets/exit_confirmation_wrapper.dart";
import "package:joby/features/company/home/manager/company_home_cubit.dart";
import "package:joby/features/company/home/presentation/screens/company_home_screen.dart";
import "package:joby/features/company/profile_company/screens/company_profile_screen.dart";
import "package:joby/features/company/saved/screens/saved_screen.dart";
import "package:joby/features/users/notification/services/local_notification_service.dart";

class CompanyRootScreen extends StatefulWidget {
  const CompanyRootScreen({super.key});

  @override
  State<CompanyRootScreen> createState() => _CompanyRootScreenState();
}

class _CompanyRootScreenState extends State<CompanyRootScreen> {
  int currentIndex = 0;
  final Set<int> _initializedTabs = {0};

  @override
  void initState() {
    super.initState();
    getIt<LocalNotificationService>().cancelAllNotifications();
  }

  void _onTabChanged(int index) {
    setState(() {
      currentIndex = index;
      _initializedTabs.add(index);
    });

    // Fetch saved seeker profiles when switching to Saved tab
    if (index == 1) {
      context.read<CompanyHomeCubit>().fetchSavedSeekers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExitConfirmationWrapper(
      child: Scaffold(
      extendBody: true,
      //
      body: IndexedStack(
        index: currentIndex,
        children: [
          const CompanyHomeScreen(),
          _initializedTabs.contains(1)
              ? const SavedScreen()
              : const SizedBox.shrink(),
          _initializedTabs.contains(2)
              ? const CompanyProfileScreen()
              : const SizedBox.shrink(),
        ],
      ),
      //
      bottomNavigationBar: Padding(
        padding: .only(left: 28.w, right: 28.w, bottom: 20.h),
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
                _navItem(index: 0, icon: "assets/svgs/home.svg", title: "Home"),
                //
                _navItem(
                  index: 1,
                  icon: "assets/svgs/saved.svg",
                  title: "Saved",
                ),
                //
                _navItem(
                  index: 2,
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
      onTap: () => _onTabChanged(index),
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
