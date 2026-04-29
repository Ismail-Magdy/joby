import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joby/core/themes/app_colors.dart';

class TotalPointsContainer extends StatelessWidget {
  const TotalPointsContainer({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: .symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.05),
        borderRadius: .circular(20.r),
        border: .all(color: AppColors.primaryColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: .min,
        children: [
          Text(
            "$text Points",
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: .bold,
              color: AppColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
