import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ionicons/ionicons.dart';
import 'package:joby/core/helpers/spacing.dart';
import 'package:joby/core/themes/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:joby/features/users/home/manager/user_home_cubit.dart';
import 'package:joby/features/users/home/manager/user_home_state.dart';
import '../widgets/points_benefit_card.dart';

class PointsScreen extends StatelessWidget {
  const PointsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserHomeCubit, UserHomeState>(
      builder: (context, state) {
        int points = 0;
        if (state is UserHomeSuccess) {
          points = state.userInfo.totalPoints;
        }
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          body: CustomScrollView(
            slivers: [
              //
              SliverAppBar(
                automaticallyImplyLeading: false,
                expandedHeight: 200.h,
                pinned: true,
                elevation: 0,
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: .vertical(bottom: .circular(30.r)),
                ),
                flexibleSpace: LayoutBuilder(
                  builder: (context, constraints) {
                    final top = constraints.biggest.height;
                    final safeAreaTop = MediaQuery.of(context).padding.top;
                    final collapsedHeight = kToolbarHeight + safeAreaTop;
                    final isCollapsed = top <= collapsedHeight + 20;
                    //
                    return FlexibleSpaceBar(
                      titlePadding: .only(
                        left: 20.w,
                        right: 20.w,
                        bottom: 15.h,
                      ),
                      //
                      title: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: isCollapsed ? 1.0 : 0.0,
                        child: Row(
                          mainAxisAlignment: .spaceBetween,
                          crossAxisAlignment: .end,
                          children: [
                            Text(
                              "Your Total Points",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.sp,
                                fontWeight: .bold,
                                fontFamily: "BrunoAceSC",
                              ),
                            ),
                            Text(
                              "$points",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                fontFamily: "BrunoAceSC",
                              ),
                            ),
                          ],
                        ),
                      ),
                      //
                      background: Container(
                        decoration: BoxDecoration(
                          borderRadius: .vertical(bottom: .circular(40.r)),
                          //
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryColor,
                              AppColors.primaryColor.withValues(alpha: 0.8),
                            ],
                            begin: .topLeft,
                            end: .bottomRight,
                          ),
                          //
                        ),
                        child: SafeArea(
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: isCollapsed ? 0.0 : 1.0,
                            child: Column(
                              mainAxisAlignment: .center,
                              children: [
                                //
                                Text(
                                  "Your Total Points",
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 20.sp,
                                    fontWeight: .w500,
                                    fontFamily: "BrunoAceSC",
                                  ),
                                ),
                                //
                                verticalSpace(10),
                                // Animated Counter
                                TweenAnimationBuilder<int>(
                                  tween: IntTween(begin: 0, end: points),
                                  duration: const Duration(seconds: 2),
                                  curve: Curves.easeOutCubic,
                                  builder: (context, value, child) {
                                    // Points Number & Icon
                                    return Row(
                                      mainAxisAlignment: .center,
                                      children: [
                                        SvgPicture.asset(
                                          "assets/svgs/points_count.svg",
                                          colorFilter: .mode(
                                            Colors.white,
                                            .srcIn,
                                          ),
                                          height: 35.h,
                                        ),
                                        //
                                        horizontalSpace(10),
                                        //
                                        Text(
                                          "$value",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 60.sp,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "BrunoAceSC",
                                          ),
                                        ),
                                      ],
                                    );
                                    //
                                  },
                                ),
                                //
                                verticalSpace(15),
                                //
                                Container(
                                  padding: .symmetric(
                                    horizontal: 16.w,
                                    vertical: 6.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: .circular(20.r),
                                  ),
                                  child: Text(
                                    "Keep checking in to level up",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ),
                                //
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                    //
                  },
                ),
              ),
              //
              SliverPadding(
                padding: .all(24.r),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Title
                    Text(
                      "Why collect points?",
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: .bold,
                        color: Colors.black87,
                        fontFamily: "BrunoAceSC",
                      ),
                    ),
                    //
                    verticalSpace(20),
                    //
                    const PointsBenefitCard(
                      title: "Daily Check in Boost",
                      description:
                          "Open the app daily to instantly receive 10 points. Consistency is key",
                      icon: Ionicons.calendar_outline,
                    ),
                    //
                    const PointsBenefitCard(
                      title: "Top Priority for Companies",
                      description:
                          "When employers search for candidates, profiles with higher point totals rank at the top of the list",
                      icon: Ionicons.trending_up_outline,
                    ),
                    //
                    const PointsBenefitCard(
                      title: "Trust Score",
                      description:
                          "A high point balance proves you are an active, eager, and committed job seeker",
                      icon: Ionicons.shield_checkmark_outline,
                    ),
                    //
                    const PointsBenefitCard(
                      title: "Featured Profile Badge",
                      description:
                          "Accumulate points to earn the 'Active Talent' badge, making your resume stand out in the crowd",
                      icon: Ionicons.ribbon_outline,
                    ),
                    //
                    const PointsBenefitCard(
                      title: "Early Job Alerts",
                      description:
                          "Top point earners receive notifications for exclusive and high-matching job openings before others",
                      icon: Ionicons.notifications_outline,
                    ),
                    //
                    const PointsBenefitCard(
                      title: "Unlock Premium Perks",
                      description:
                          "Keep growing your balance to eventually unlock future rewards and direct communication with recruiters",
                      icon: Ionicons.diamond_outline,
                    ),
                    //
                    verticalSpace(90),
                    //
                  ]),
                ),
              ),
              //
            ],
          ),
        );
      },
    );
  }
}
