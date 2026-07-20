import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joby/core/helpers/spacing.dart';

class ProfileViewsCardWithoutTime extends StatelessWidget {
  const ProfileViewsCardWithoutTime({
    super.key,
    required this.viewCompanyName,
    required this.viewViewCountInt,
    required this.viewViewCountString,
  });
  final String viewCompanyName;
  final int viewViewCountInt;
  final String viewViewCountString;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        //
        Flexible(
          child: Text(
            viewCompanyName,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: .bold,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: .ellipsis,
          ),
        ),
        //
        if (viewViewCountInt > 1) ...[
          //
          horizontalSpace(10),
          //
          Container(
            padding: .symmetric(horizontal: 6.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.15),
              borderRadius: .circular(6.r),
            ),
            child: Row(
              mainAxisSize: .min,
              children: [
                //
                Icon(
                  Icons.local_fire_department_rounded,
                  color: Colors.orange,
                  size: 12.sp,
                ),
                //
                horizontalSpace(2),
                //
                Text(
                  viewViewCountString,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: .bold,
                    color: Colors.orange,
                  ),
                ),
                //
              ],
            ),
          ),
          //
        ],
      ],
    );
    //
  }
}
