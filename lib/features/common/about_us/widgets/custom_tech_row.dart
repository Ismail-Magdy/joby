import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helpers/spacing.dart';

class CustomTechRow extends StatelessWidget {
  const CustomTechRow({
    super.key,
    required this.icon,
    required this.name,
    required this.description,
    this.isLast = false,
  });
  final IconData icon;
  final String name;
  final String description;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: .only(bottom: isLast ? 0 : 14.h),
      child: Row(
        children: [
          //
          Container(
            padding: .all(8.r),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: .circular(10.r),
              border: .all(color: Colors.grey.shade200),
            ),
            child: Icon(icon, size: 18.sp, color: Colors.grey.shade600),
          ),
          //
          horizontalSpace(12),
          //
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                //
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: .bold,
                    color: Colors.black87,
                  ),
                ),
                //
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
                //
              ],
            ),
          ),
          //
        ],
      ),
    );
  }
}
