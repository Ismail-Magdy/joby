import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ionicons/ionicons.dart';
import 'package:joby/core/helpers/spacing.dart';
import 'package:joby/core/themes/app_colors.dart';

class CvUploadWidget extends StatelessWidget {
  const CvUploadWidget({
    super.key,
    required this.onTap,
    required this.pickedCvName,
  });
  final void Function()? onTap;
  final String? pickedCvName;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: .infinity,
        padding: .symmetric(
          vertical: pickedCvName != null ? 15.h : 20.h,
          horizontal: 15.w,
        ),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withValues(alpha: 0.05),
          border: .all(
            color: AppColors.primaryColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
          borderRadius: .circular(16.r),
        ),
        child: Column(
          children: [
            Icon(
              pickedCvName != null
                  ? Ionicons.document_text
                  : Ionicons.cloud_upload_outline,
              color: AppColors.primaryColor,
              size: 35.sp,
            ),
            verticalSpace(10),
            Text(
              pickedCvName ?? "Upload New CV (PDF)",
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.primaryColor,
                fontWeight: .w600,
              ),
              textAlign: .center,
              maxLines: 1,
              overflow: .ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
