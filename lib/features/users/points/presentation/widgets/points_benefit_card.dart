import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joby/core/helpers/spacing.dart';
import 'package:joby/core/themes/app_colors.dart';

class PointsBenefitCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const PointsBenefitCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: .only(bottom: 16.h),
      padding: .all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: .circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 15.r,
            spreadRadius: 2.r,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: .start,
        children: [
          //
          Container(
            padding: .all(12.r),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.05),
              shape: .circle,
            ),
            child: Icon(
              icon,
              color: AppColors.primaryColor.withValues(alpha: 0.7),
              size: 26.sp,
            ),
          ),
          //
          horizontalSpace(16),
          //
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                //
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: .bold,
                    color: Colors.black87,
                  ),
                ),
                //
                verticalSpace(6),
                //
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
                //
              ],
            ),
          ),
          //
        ],
      ),
    );
  }
}
