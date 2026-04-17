import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ionicons/ionicons.dart';
import '../../../../../core/helpers/spacing.dart';
import '../../../../../core/themes/app_colors.dart';

class CustomHeadSection extends StatelessWidget {
  const CustomHeadSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            padding: .all(22.r),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.08),
              shape: .circle,
            ),
            child: Icon(
              Ionicons.chatbubble_ellipses_outline,
              color: AppColors.primaryColor,
              size: 42.sp,
            ),
          ),
          verticalSpace(18),
          Text(
            "Your Voice Matters",
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: .bold,
              color: Colors.black87,
            ),
          ),
          verticalSpace(10),
          Text(
            "We read every suggestion.\nHelp us make Joby even better",
            textAlign: .center,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade600,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}
