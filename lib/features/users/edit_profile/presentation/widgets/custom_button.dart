import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/themes/app_colors.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({super.key});

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
        onPressed: () {
          // TODO: ربط الداتا بالكيوبت
        },
        child: Text(
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
