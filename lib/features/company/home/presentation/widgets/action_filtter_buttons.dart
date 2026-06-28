import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joby/core/helpers/spacing.dart';
import 'package:joby/core/themes/app_colors.dart';

class ActionFiltterButtons extends StatelessWidget {
  const ActionFiltterButtons({
    super.key,
    required this.onPressed,
    required this.onPressedClearFilters,
  });
  final void Function() onPressed;
  final void Function() onPressedClearFilters;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        //
        Expanded(
          child: OutlinedButton(
            onPressed: onPressedClearFilters,
            style: OutlinedButton.styleFrom(
              padding: .symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(borderRadius: .circular(12.r)),
              side: BorderSide(color: AppColors.primaryColor),
            ),
            child: Text(
              "Reset",
              style: TextStyle(color: AppColors.primaryColor, fontSize: 16.sp),
            ),
          ),
        ),
        //
        horizontalSpace(16),
        //
        Expanded(
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              padding: .symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(borderRadius: .circular(12.r)),
            ),
            child: Text(
              "Apply Filters",
              style: TextStyle(color: Colors.white, fontSize: 16.sp),
            ),
          ),
        ),
        //
      ],
    );
    //
  }
}
