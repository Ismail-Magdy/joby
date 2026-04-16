import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";
import "package:flutter_svg/svg.dart";
import "package:joby/features/users/ai/manager/ai_chat_cubit.dart";

import "../../../../core/helpers/spacing.dart";
import "../../../../core/themes/app_colors.dart";
import "../../ai/presentation/screens/ai_chat_screen.dart";
import "../../home/presentation/screens/user_home_screen.dart";
import "../../settings/presentation/screens/user_settings_screen.dart";

class UserRootScreen extends StatefulWidget {
  const UserRootScreen({super.key});

  @override
  State<UserRootScreen> createState() => _UserRootScreenState();
}

class _UserRootScreenState extends State<UserRootScreen> {
  //
  List<Widget> screens = [
    const UserHomeScreen(),
    const AiChatScreen(),
    const UserSettingsScreen(),
  ];
  //
  int currentIndex = 0;
  //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //
      extendBody: true,
      //
      body: IndexedStack(
        index: currentIndex,
        children: [
          const UserHomeScreen(),
          BlocProvider(
            create: (context) => AiChatCubit(),
            child: const AiChatScreen(),
          ),
          const UserSettingsScreen(),
        ],
      ),
      //
      bottomNavigationBar: Padding(
        padding: .only(left: 40.w, right: 40.w, bottom: 25.h),
        child: Container(
          height: 68.h,
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: .circular(40.r),
          ),
          child: Row(
            mainAxisAlignment: .spaceAround,
            children: [
              // Profile Item
              customIconNavigationBar(
                index: 0,
                icon: "assets/svgs/profile.svg",
                title: "Profile",
              ),
              // AI Chat
              customIconNavigationBar(
                index: 1,
                icon: "assets/svgs/chat.svg",
                title: "Ask Joby",
              ),
              // Settings Item
              customIconNavigationBar(
                index: 2,
                icon: "assets/svgs/settings.svg",
                title: "Settings",
              ),
            ],
          ),
        ),
      ),
      //
    );
  }

  // Icon Navigation Bar
  Widget customIconNavigationBar({
    required int index,
    required String icon,
    required String title,
  }) {
    bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          currentIndex = index;
        });
      },
      child: Column(
        mainAxisAlignment: .center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: isSelected ? 38.h : 35.h,
            width: isSelected ? 38.w : 35.w,
            decoration: BoxDecoration(
              shape: .circle,
              color: isSelected
                  ? const Color(0xffB9E5E8).withValues(alpha: 0.4)
                  : Colors.transparent,
            ),
            child: Center(
              child: AnimatedScale(
                duration: const Duration(milliseconds: 300),
                scale: isSelected ? 1.1 : 1.0,
                child: SvgPicture.asset(
                  icon,
                  height: 22.h,
                  colorFilter: const .mode(Colors.white, .srcIn),
                ),
              ),
            ),
          ),
          //
          verticalSpace(isSelected ? 2 : 3),
          //
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontFamily: "BrunoAceSC",
              color: Colors.white,
              fontSize: isSelected ? 12.sp : 10.sp,
              fontWeight: isSelected ? .bold : .normal,
            ),
            child: Text(title),
          ),
          //
        ],
      ),
    );
  }

  //
}
