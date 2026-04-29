import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joby/core/themes/app_colors.dart';

class CustomSearchContainer extends StatelessWidget {
  const CustomSearchContainer({
    super.key,
    required this.searchController,
    required this.searchFocusNode,
    required this.onChanged,
    required this.onPressed,
  });
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final Function(String) onChanged;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: .circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: searchController,
        focusNode: searchFocusNode,
        onChanged: onChanged,
        style: TextStyle(fontSize: 14.sp),
        decoration: InputDecoration(
          hintText: "Search for a location",
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.primaryColor,
            size: 22.sp,
          ),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Colors.grey.shade500,
                    size: 20.sp,
                  ),
                  onPressed: onPressed,
                )
              : null,
          border: .none,
          contentPadding: .symmetric(horizontal: 16.w, vertical: 14.h),
        ),
      ),
    );
  }
}
