import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joby/core/helpers/spacing.dart';
import 'package:joby/core/themes/app_colors.dart';

class PreviewChipWidget extends StatelessWidget {
  const PreviewChipWidget({
    super.key,
    required this.icon,
    required this.label,
    this.isPrimary = false,
  });
  final IconData icon;
  final String label;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: .symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isPrimary
            ? AppColors.primaryColor.withValues(alpha: 0.1)
            : Colors.grey.shade100,
        borderRadius: .circular(12.r),
        border: isPrimary
            ? .all(
                color: AppColors.primaryColor.withValues(alpha: 0.2),
                width: 1,
              )
            : null,
      ),
      child: Row(
        mainAxisSize: .min,
        children: [
          Icon(
            icon,
            size: 14.sp,
            color: isPrimary ? AppColors.primaryColor : Colors.grey.shade600,
          ),
          //
          horizontalSpace(6),
          //
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: .w600,
              color: isPrimary ? AppColors.primaryColor : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
