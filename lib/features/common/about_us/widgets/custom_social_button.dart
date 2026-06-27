import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/helpers/spacing.dart';

class CustomSocialButton extends StatelessWidget {
  const CustomSocialButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          //
          Container(
            padding: .all(14.r),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: .circle,
            ),
            child: Icon(icon, color: color, size: 25.sp),
          ),
          //
          verticalSpace(8),
          //
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.grey.shade700,
              fontWeight: .w500,
            ),
          ),
          //
        ],
      ),
    );
  }
}
