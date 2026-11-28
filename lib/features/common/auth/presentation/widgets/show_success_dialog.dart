import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joby/core/helpers/spacing.dart';

class ShowSuccessDialog extends StatelessWidget {
  const ShowSuccessDialog({super.key, required this.onPressed});
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
          Icon(Icons.check_circle_outline, color: Colors.green, size: 60.sp),
          verticalSpace(16),
          Text(
            "Verification Successful",
            style: TextStyle(
              fontFamily: "BrunoAceSC",
              color: Colors.green,
              fontSize: 16.sp,
            ),
            textAlign: .center,
          ),
          //
          verticalSpace(12),
          //
          Text(
            "You Can Now Log In",
            style: TextStyle(fontSize: 14.sp),
            textAlign: .center,
          ),
          verticalSpace(40),
          SizedBox(
            width: .infinity,
            height: 50.h,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
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
