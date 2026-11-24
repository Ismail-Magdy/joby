import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:joby/core/helpers/spacing.dart';
import 'package:joby/core/themes/app_colors.dart';
import 'package:joby/features/users/profile_views/manager/profile_views_state.dart';

class BuildStatsCard extends StatelessWidget {
  const BuildStatsCard({super.key, required this.state});
  final ProfileViewsLoaded state;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: .symmetric(horizontal: 20.w, vertical: 22.h),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.09),
        borderRadius: .circular(16.r),
      ),
      child: Row(
        mainAxisAlignment: .spaceBetween,
        children: [
          Row(
            children: [
              //
              Container(
                padding: .all(10.w),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: .circle,
                ),
                child: SvgPicture.asset(
                  "assets/svgs/eye.svg",
                  height: 22.h,
                  colorFilter: const .mode(AppColors.primaryColor, .srcIn),
                ),
              ),
              //
              horizontalSpace(15),
              //
              Column(
                crossAxisAlignment: .start,
                children: [
                  //
                  Text(
                    "${state.totalViews}",
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: .w900,
                      color: AppColors.primaryColor,
                      height: 1.2,
                    ),
                  ),
                  //
                  Text(
                    "Total Profile Views",
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey.shade600,
                      fontWeight: .w500,
                    ),
                  ),
                  //
                ],
              ),
              //
            ],
          ),
          //
          // Right Side
          Column(
            crossAxisAlignment: .end,
            children: [
              //
              Row(
                children: [
                  //
                  Text(
                    "${state.trendDifference}%",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: .bold,
                      color: state.isTrendUp ? Colors.green : Colors.red,
                    ),
                  ),
                  //
                  horizontalSpace(2),
                  //
                  Icon(
                    state.isTrendUp ? Icons.north_east : Icons.south_east,
                    color: state.isTrendUp ? Colors.green : Colors.red,
                    size: 18.sp,
                  ),
                  //
                ],
              ),
              //
              verticalSpace(4),
              //
              Text(
                "Last Week",
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey.shade600,
                  fontWeight: .w500,
                ),
              ),
              //
            ],
          ),
          //
        ],
      ),
    );
  }
}
