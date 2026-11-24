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
                      // Scroll Screen
                      title: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: isCollapsed ? 1.0 : 0.0,
                        child: Row(
                          mainAxisAlignment: .spaceBetween,
                          crossAxisAlignment: .end,
                          children: [
                            //
                            Text(
                              "Your Total Points",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.sp,
                                fontWeight: .bold,
                                fontFamily: "BrunoAceSC",
                              ),
                            ),
                            //
                            Text(
                              "$points",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                fontFamily: "BrunoAceSC",
                              ),
                            ),
                            //
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
                        // Normal Screen
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
                                //
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
                                        //
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
                                            fontWeight: .bold,
                                            fontFamily: "BrunoAceSC",
                                          ),
                                        ),
                                        //
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
                                    "Keep Checking in To Level Up",
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
                      "Why Collect Points?",
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
                          "Open The App Daily to Instantly Receive 10 Points. Consistency is Key",
                      icon: Ionicons.calendarOutline,
                    ),
                    //
                    const PointsBenefitCard(
                      title: "Top Priority",
                      description:
                          "Profiles with Higher Point Totals Rank at The Top of The List",
                      icon: Ionicons.trendingUpOutline,
                    ),
                    //
                    const PointsBenefitCard(
                      title: "Trust Score",
                      description:
                          "A high Point Balance Proves You are an Active, Eager, and Committed Job Seeker",
                      icon: Ionicons.shieldCheckmarkOutline,
                    ),
                    //
                    const PointsBenefitCard(
                      title: "Featured Profile Badge",
                      description:
                          "Accumulate Points to Earn the 'Active Talent' Badge, Making Your Resume Stand out in The Crowd",
                      icon: Ionicons.ribbonOutline,
                    ),
                    //
                    const PointsBenefitCard(
                      title: "Unlock Premium Perks",
                      description:
                          "Keep Growing Your Balance to Eventually Unlock Future Rewards and Direct Communication with Recruiters",
                      icon: Ionicons.diamondOutline,
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
// 260
