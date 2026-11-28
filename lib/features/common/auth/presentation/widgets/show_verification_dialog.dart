import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joby/core/helpers/spacing.dart';
import 'package:joby/core/themes/app_colors.dart';

class ShowVerificationDialog extends StatelessWidget {
  const ShowVerificationDialog({super.key, required this.onPressed});
  final void Function() onPressed;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280.w,
      height: 280.w,
      padding: .all(24.r),
      child: Column(
        mainAxisAlignment: .center,
        children: [
          Icon(
            Icons.mark_email_read_outlined,
            color: AppColors.primaryColor,
            size: 60.sp,
          ),
          verticalSpace(16),
          Text(
            "Check Your Email",
            style: TextStyle(
              fontFamily: "BrunoAceSC",
              color: AppColors.primaryColor,
              fontSize: 18.sp,
            ),
            textAlign: .center,
          ),
          verticalSpace(12),
          Text(
            "We've Sent a Verification Link, Please Click It to Verify Your Account",
            style: TextStyle(fontSize: 14.sp),
            textAlign: .center,
          ),
          const Spacer(),
          SizedBox(
            width: .infinity,
            height: 50.h,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: .circular(10.r)),
              ),
              onPressed: onPressed,
              child: Text(
                "OK",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: .bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
