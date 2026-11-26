import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joby/core/helpers/spacing.dart';
import 'package:joby/core/themes/app_colors.dart';

class SettingsGroupCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingsGroupCard({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Padding(
          padding: .only(left: 4.w, bottom: 8.h),
          child: Text(
            title,
            style: TextStyle(
              fontFamily: 'BrunoAceSC',
              fontSize: 11.sp,
              fontWeight: .bold,
              letterSpacing: 1.0,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: .circular(16.r),
            border: .all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: .circular(16.r),
            child: Column(children: _buildSeparatedChildren()),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSeparatedChildren() {
    final List<Widget> items = [];
    for (int i = 0; i < children.length; i++) {
      items.add(children[i]);
      if (i < children.length - 1) {
        items.add(
          Divider(
            height: 1,
            thickness: 1,
            indent: 16.w,
            endIndent: 16.w,
            color: Colors.grey.shade100,
          ),
        );
      }
    }
    return items;
  }
}

class SettingsTileItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const SettingsTileItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: .symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.08),
                borderRadius: .circular(12.r),
              ),
              child: Icon(icon, color: AppColors.primaryColor, size: 20.sp),
            ),
            horizontalSpace(14),
            Expanded(
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    verticalSpace(2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            horizontalSpace(8),
            trailing ??
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 15.sp,
                  color: Colors.grey.shade400,
                ),
          ],
        ),
      ),
    );
  }
}
