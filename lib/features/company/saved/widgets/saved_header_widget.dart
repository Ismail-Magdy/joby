import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joby/core/themes/app_colors.dart';

class SavedHeaderWidget extends StatelessWidget {
  const SavedHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: .only(top: 54.h, bottom: 20.h),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: .only(
          bottomLeft: .circular(20.r),
          bottomRight: .circular(20.r),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: Text(
          "Saved Talents",
          style: TextStyle(
            fontFamily: "BrunoAceSC",
            fontSize: 20.sp,
            color: Colors.white,
            fontWeight: .bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
