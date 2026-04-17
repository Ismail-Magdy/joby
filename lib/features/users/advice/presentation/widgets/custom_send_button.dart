import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ionicons/ionicons.dart';
import '../../../../../core/themes/app_colors.dart';

class CustomSendButton extends StatelessWidget {
  const CustomSendButton({super.key, required this.onPressed});
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: .infinity,
      height: 56.h,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          shape: RoundedRectangleBorder(borderRadius: .circular(16.r)),
          elevation: 0,
        ),
        icon: Icon(Ionicons.send_outline, color: Colors.white, size: 20.sp),
        label: Text(
          "Send Feedback",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: .bold,
          ),
        ),
      ),
    );
  }
}
