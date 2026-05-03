import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ionicons/ionicons.dart';
import 'package:joby/core/helpers/spacing.dart';
import 'package:joby/core/themes/app_colors.dart';

class CvSection extends StatelessWidget {
  const CvSection({super.key, required this.onTap});
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: .symmetric(horizontal: 18.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withValues(alpha: 0.06),
          borderRadius: .circular(16.r),
          border: .all(color: AppColors.primaryColor.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Container(
              padding: .all(10.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: .circular(10.r),
              ),
              child: Icon(
                Ionicons.document_text_outline,
                color: AppColors.primaryColor,
                size: 26.sp,
              ),
            ),
            horizontalSpace(15),
            Expanded(
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Text(
                    "My Resume",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  verticalSpace(3),
                  Text(
                    "PDF Document",
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            SvgPicture.asset(
              "assets/svgs/show_cv.svg",
              colorFilter: .mode(AppColors.primaryColor, .srcIn),
              height: 20.h,
            ),
          ],
        ),
      ),
    );
  }
}
