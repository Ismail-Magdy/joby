import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../../core/themes/app_colors.dart';

class CustomSettingsItem extends StatelessWidget {
  const CustomSettingsItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLogout,
  });
  final String icon;
  final String label;
  final VoidCallback onTap;
  final bool? isLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: .symmetric(vertical: 8.h),
      padding: .symmetric(vertical: 20.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: .circular(12.r),
        border: .all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: SvgPicture.asset(
          icon,
          colorFilter: .mode(
            isLogout ?? false ? Colors.red : AppColors.primaryColor,
            .srcIn,
          ),
          height: 24.h,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontFamily: "BrunoAceSC",
            fontSize: 16.sp,
            color: isLogout ?? false ? Colors.red : Colors.black87,
            fontWeight: isLogout ?? false ? .bold : .normal,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16.sp,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}
