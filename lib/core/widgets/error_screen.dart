import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joby/core/themes/app_colors.dart';
import '../helpers/spacing.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: .symmetric(horizontal: 20.w, vertical: 10.h),
        child: Column(
          mainAxisAlignment: .center,
          crossAxisAlignment: .center,
          children: [
            Center(
              child: Image.asset(
                "assets/images/error-404.png",
                height: 100.h,
                width: 100.w,
                color: AppColors.primaryColor,
              ),
            ),
            //
            verticalSpace(30),
            //
            Text(
              "An Error Occurred",
              style: TextStyle(
                fontFamily: "BrunoAceSC",
                fontSize: 16.sp,
                fontWeight: .bold,
                color: Colors.black,
              ),
            ),
            //
            verticalSpace(16),
            //
            Text(
              "An Error Occurred While Loading Page",
              textAlign: .center,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: .bold,
                height: 1.5.h,
                color: AppColors.primaryColor,
              ),
            ),
            //
          ],
        ),
      ),
    );
  }
}
