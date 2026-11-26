import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:joby/core/helpers/spacing.dart';
import 'package:joby/core/themes/app_colors.dart';

class CompanySummaryCard extends StatelessWidget {
  final String companyName;
  final String? avatarUrl;
  final bool isLoading;
  final VoidCallback onEditTap;

  const CompanySummaryCard({
    super.key,
    required this.companyName,
    this.avatarUrl,
    this.isLoading = false,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = companyName.trim().isNotEmpty
        ? companyName.trim()
        : "Company Account";

    return InkWell(
      onTap: onEditTap,
      borderRadius: .circular(18.r),
      child: Container(
        padding: .all(16.r),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: .circular(18.r),
          border: .all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 58.w,
              height: 58.w,
              decoration: BoxDecoration(
                shape: .circle,
                color: AppColors.primaryColor.withValues(alpha: 0.08),
                border: .all(
                  color: AppColors.primaryColor.withValues(alpha: 0.25),
                  width: 1.5,
                ),
              ),
              child: ClipOval(
                child: avatarUrl != null && avatarUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: avatarUrl!,
                        fit: .cover,
                        placeholder: (_, _) =>
                            const Center(child: CupertinoActivityIndicator()),
                        errorWidget: (_, _, _) => Icon(
                          Icons.business_rounded,
                          color: AppColors.primaryColor,
                          size: 28.sp,
                        ),
                      )
                    : Icon(
                        Icons.business_rounded,
                        color: AppColors.primaryColor,
                        size: 28.sp,
                      ),
              ),
            ),
            horizontalSpace(14),
            Expanded(
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Text(
                    isLoading && companyName.isEmpty ? "Loading" : displayName,
                    maxLines: 1,
                    overflow: .ellipsis,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: .bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  verticalSpace(3),
                  Text(
                    "Tap Edit To Update Company Name & Logo",
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            horizontalSpace(10),
            Container(
              padding: .all(9.r),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.08),
                borderRadius: .circular(12.r),
              ),
              child: SvgPicture.asset(
                "assets/svgs/pen_edit.svg",
                width: 20.w,
                height: 20.h,
                colorFilter: .mode(AppColors.primaryColor, .srcIn),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
