import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joby/core/helpers/spacing.dart';
import 'package:joby/core/themes/app_colors.dart';
import 'package:lottie/lottie.dart';

class UnknownRouteScreen extends StatelessWidget {
  const UnknownRouteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: .symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: .center,
            children: [
              Lottie.asset(
                "assets/lottie/no_data.json",
                width: 250.w,
                height: 250.h,
              ),
              verticalSpace(12),
              Text(
                "Page Not Found",
                textAlign: .center,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: .bold,
                  color: AppColors.black,
                ),
              ),
              verticalSpace(12),
              Text(
                "The Page You Are Looking For Does Not Exist",
                textAlign: .center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
