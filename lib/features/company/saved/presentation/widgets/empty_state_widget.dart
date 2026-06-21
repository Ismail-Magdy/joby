import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joby/core/helpers/spacing.dart';
import 'package:joby/core/themes/app_colors.dart';

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: .symmetric(horizontal: 40.w),
        child: Column(
          mainAxisAlignment: .center,
          children: [
            Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                shape: .circle,
                gradient: LinearGradient(
                  begin: .topLeft,
                  end: .bottomRight,
                  colors: [
                    AppColors.primaryColor.withValues(alpha: 0.08),
                    AppColors.primaryColor.withValues(alpha: 0.18),
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.bookmark_outline_rounded,
                  size: 56.sp,
                  color: AppColors.primaryColor.withValues(alpha: 0.55),
                ),
              ),
            ),
            verticalSpace(28),
            Text(
              "No Saved Talents Yet",
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: .w700,
                color: Colors.grey.shade800,
                letterSpacing: 0.3,
              ),
            ),

            verticalSpace(32),
            Container(
              padding: .symmetric(horizontal: 16.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.07),
                borderRadius: .circular(30.r),
                border: .all(
                  color: AppColors.primaryColor.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                mainAxisSize: .min,
                children: [
                  Icon(
                    Icons.touch_app_rounded,
                    size: 18.sp,
                    color: AppColors.primaryColor.withValues(alpha: 0.6),
                  ),
                  horizontalSpace(8.w),
                  Text(
                    "Tap the bookmark icon on any card",
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.primaryColor.withValues(alpha: 0.7),
                      fontWeight: .w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
