import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joby/core/themes/app_colors.dart';

class AppTextStyles {
  static TextStyle dialogTitle(Color color) => TextStyle(
    fontFamily: "Poppins",
    fontSize: 18.sp,
    fontWeight: .bold,
    color: color,
  );

  static TextStyle get dialogMessage => TextStyle(
    fontFamily: "Poppins",
    fontSize: 14.sp,
    fontWeight: .w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );
}
