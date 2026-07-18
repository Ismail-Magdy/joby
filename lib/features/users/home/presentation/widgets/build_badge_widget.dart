import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joby/core/helpers/spacing.dart';

class BuildBadgeWidget extends StatelessWidget {
  const BuildBadgeWidget({super.key, required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: .symmetric(horizontal: 14.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: .circular(20.r),
        border: .all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          //
          Icon(icon, size: 17.sp, color: Colors.grey.shade600),
          //
          horizontalSpace(6),
          //
          Text(
            text,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: .w600,
              color: Colors.grey.shade800,
            ),
          ),
          //
        ],
      ),
    );
  }
}
