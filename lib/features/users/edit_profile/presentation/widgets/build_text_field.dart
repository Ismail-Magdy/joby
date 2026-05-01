import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joby/core/helpers/spacing.dart';
import '../../../../../core/themes/app_colors.dart';

class BuildTextField extends StatelessWidget {
  const BuildTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.iconColor,
    this.keyboardType,
    this.validator,
    this.autovalidateMode,
    this.onChanged,
  });
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final Color iconColor;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;
  final void Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: .w600,
            color: Colors.grey.shade700,
          ),
        ),
        verticalSpace(8),
        TextFormField(
          keyboardType: keyboardType,
          controller: controller,
          validator: validator,
          autovalidateMode: autovalidateMode,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13.sp),
            prefixIcon: Icon(icon, color: iconColor, size: 22.sp),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: .symmetric(horizontal: 20.w, vertical: 16.h),
            border: OutlineInputBorder(
              borderRadius: .circular(14.r),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: .circular(14.r),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: .circular(14.r),
              borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: .circular(14.r),
              borderSide: BorderSide(color: Colors.red, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: .circular(14.r),
              borderSide: BorderSide(color: Colors.red, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
