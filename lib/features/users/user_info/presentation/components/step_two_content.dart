import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joby/core/helpers/spacing.dart';
import 'package:joby/core/themes/app_colors.dart';

class StepTwoContent extends StatelessWidget {
  const StepTwoContent({
    super.key,
    required this.onChangedLevel,
    required this.onChangedTypeOfWork,
  });
  final void Function(String?)? onChangedLevel;
  final void Function(String?)? onChangedTypeOfWork;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //
        verticalSpace(10),
        //
        DropdownButtonFormField<String>(
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.primaryColor,
          ),
          dropdownColor: Colors.white,
          borderRadius: .circular(12.r),
          decoration: InputDecoration(
            labelText: "Level",
            prefixIcon: Icon(
              Icons.leaderboard_outlined,
              color: Colors.grey.shade600,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: .symmetric(horizontal: 16.w, vertical: 14.h),
            border: OutlineInputBorder(
              borderRadius: .circular(12.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: .circular(12.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: .circular(12.r),
              borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5),
            ),
          ),
          items: ["Junior", "Mid-Level", "Senior", "Lead"].map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: onChangedLevel,
        ),
        //
        verticalSpace(15),
        //
        DropdownButtonFormField<String>(
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.primaryColor,
          ),
          dropdownColor: Colors.white,
          borderRadius: .circular(12.r),
          decoration: InputDecoration(
            labelText: "Type of Work",
            prefixIcon: Icon(
              Icons.business_center_outlined,
              color: Colors.grey.shade600,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: .symmetric(horizontal: 16.w, vertical: 14.h),
            border: OutlineInputBorder(
              borderRadius: .circular(12.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: .circular(12.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: .circular(12.r),
              borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5),
            ),
          ),
          items: ["Remote", "On-site", "Hybrid"].map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: onChangedTypeOfWork,
        ),
        //
      ],
    );
    //
  }
}
