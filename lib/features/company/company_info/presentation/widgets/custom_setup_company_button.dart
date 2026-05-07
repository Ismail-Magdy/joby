import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joby/core/themes/app_colors.dart';

class CustomSetupCompanyButton extends StatelessWidget {
  const CustomSetupCompanyButton({
    super.key,
    required this.onPressed,
    required this.child,
  });
  final void Function()? onPressed;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: .infinity,
      height: 55.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          shape: RoundedRectangleBorder(borderRadius: .circular(14.r)),
          elevation: 0,
        ),
        child: child,
      ),
    );
  }
}
