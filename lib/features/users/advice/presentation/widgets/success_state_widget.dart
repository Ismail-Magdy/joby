import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../../core/helpers/spacing.dart';
import '../../../../../core/themes/app_colors.dart';

class SuccessStateWidget extends StatelessWidget {
  const SuccessStateWidget({super.key, required this.onPressed});
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: .infinity,
      padding: .all(24.r),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.07),
        borderRadius: .circular(16.r),
        border: .all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(
            Ionicons.checkmark_circle_outline,
            color: Colors.green,
            size: 52.sp,
          ),
          verticalSpace(12),
          Text(
            "Thank you for your feedback",
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: .bold,
              color: Colors.green.shade700,
            ),
          ),
          verticalSpace(8),
          Text(
            "Your feedback has been sent successfully "
            "We appreciate you helping us improve Joby",
            textAlign: .center,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
          verticalSpace(16),
          TextButton(
            onPressed: onPressed,
            child: Text(
              "Send Another",
              style: TextStyle(
                color: AppColors.primaryColor,
                fontSize: 14.sp,
                fontWeight: .w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
