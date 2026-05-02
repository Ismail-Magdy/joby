import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joby/core/themes/app_colors.dart';

class CustomSaveButton extends StatelessWidget {
  const CustomSaveButton({
    super.key,
    required this.onPressed,
    required this.isLoading,
  });
  final void Function()? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: .infinity,
      height: 55.h,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          shape: RoundedRectangleBorder(borderRadius: .circular(16.r)),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: isLoading
            ? const CupertinoActivityIndicator(color: Colors.white)
            : Text(
                "Save Changes",
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
