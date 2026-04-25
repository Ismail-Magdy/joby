import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joby/core/themes/app_colors.dart';

/// Builds a styled dropdown matching the app's design system.

class DropDownWidget extends StatelessWidget {
  const DropDownWidget({
    super.key,
    this.value,
    required this.hint,
    required this.icon,
    required this.items,
    required this.onChanged,
  });
  final String? value;
  final String hint;
  final IconData icon;
  final List<String> items;
  final void Function(String?) onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: AppColors.primaryColor,
      ),
      dropdownColor: Colors.white,
      borderRadius: .circular(12.r),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13.sp),
        prefixIcon: Icon(icon, color: Colors.grey.shade600, size: 22.sp),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: .symmetric(horizontal: 20.w, vertical: 16.h),
        border: OutlineInputBorder(
          borderRadius: .circular(14.r),
          borderSide: .none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: .circular(14.r),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: .circular(14.r),
          borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5),
        ),
      ),
      items: items.map((String val) {
        return DropdownMenuItem<String>(value: val, child: Text(val));
      }).toList(),
      onChanged: onChanged,
    );
  }
}
