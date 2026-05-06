import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joby/core/helpers/spacing.dart';

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: .center,
        children: [
          Icon(
            CupertinoIcons.bell_slash,
            size: 80.sp,
            color: Colors.grey.shade400,
          ),
          verticalSpace(20),
          Text(
            "No new notifications yet",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: .w600,
              color: Colors.grey.shade700,
            ),
          ),
          verticalSpace(10),
          Text(
            "We'll notify you when something\nimportant happens.",
            textAlign: .center,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
