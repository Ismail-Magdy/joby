import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/helpers/spacing.dart';
import '../../../../../core/themes/app_colors.dart';

class CardWidget extends StatelessWidget {
  const CardWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
  });
  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: .all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: .circular(16.r),
        border: .all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              Container(
                padding: .all(8.r),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.08),
                  borderRadius: .circular(10.r),
                ),
                child: Icon(icon, color: AppColors.primaryColor, size: 20.sp),
              ),
              horizontalSpace(12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: .bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          verticalSpace(16),
          child,
        ],
      ),
    );
  }
}
