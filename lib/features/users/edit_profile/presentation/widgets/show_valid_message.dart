import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joby/core/helpers/spacing.dart';

class ShowValidMessage extends StatelessWidget {
  const ShowValidMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: .only(top: 8.h),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 16.sp),
          //
          horizontalSpace(5),
          //
          Text(
            "Valid Phone Number Format",
            style: TextStyle(color: Colors.green, fontSize: 12.sp),
          ),
        ],
      ),
    );
  }
}
