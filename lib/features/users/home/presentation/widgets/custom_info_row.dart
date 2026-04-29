import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ionicons/ionicons.dart';
import 'package:joby/core/helpers/spacing.dart';
import 'package:joby/core/themes/app_colors.dart';
import 'package:joby/features/users/home/presentation/widgets/build_badge_widget.dart';

class CustomInfoRow extends StatelessWidget {
  const CustomInfoRow({
    super.key,
    required this.levelText,
    required this.jobCategoryText,
    required this.typeOfWorkText,
  });
  final String levelText;
  final String jobCategoryText;
  final String typeOfWorkText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: .symmetric(horizontal: 10.w),
      child: Row(
        mainAxisAlignment: .center,
        children: [
          BuildBadgeWidget(icon: Ionicons.stats_chart_outline, text: levelText),
          horizontalSpace(15),
          Container(
            padding: .symmetric(horizontal: 14.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.1),
              borderRadius: .circular(20.r),
              border: Border.all(
                color: AppColors.primaryColor.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              jobCategoryText,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
          ),
          horizontalSpace(15),
          BuildBadgeWidget(
            icon: Ionicons.business_outline,
            text: typeOfWorkText,
          ),
        ],
      ),
    );
  }
}
