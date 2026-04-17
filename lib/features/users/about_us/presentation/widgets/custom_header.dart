import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../core/helpers/spacing.dart';
import '../../../../../core/themes/app_colors.dart';

class CustomHeader extends StatelessWidget {
  const CustomHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: .infinity,
      padding: .symmetric(vertical: 40.h),
      decoration: BoxDecoration(
        borderRadius: .only(
          bottomLeft: .circular(50.r),
          bottomRight: .circular(50.r),
        ),
        gradient: LinearGradient(
          begin: .topLeft,
          end: .bottomRight,
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withValues(alpha: 0.75),
          ],
        ),
      ),
      child: Column(
        children: [
          SvgPicture.asset(
            "assets/svgs/joby_logo.svg",
            height: 58.h,
            colorFilter: const .mode(Colors.white, .srcIn),
          ),
          verticalSpace(6),
          Text(
            "Connecting Talent with Opportunity",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13.sp,
            ),
          ),
          verticalSpace(14),
          Container(
            padding: .symmetric(horizontal: 16.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: .circular(20.r),
            ),
            child: Text(
              "v 1.0.0",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: .w600,
              ),
            ),
          ),
        ],
      ),
    );
    //
  }
}
