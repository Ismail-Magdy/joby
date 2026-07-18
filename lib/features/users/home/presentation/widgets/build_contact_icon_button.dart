import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BuildContactIconButton extends StatelessWidget {
  const BuildContactIconButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: .all(12.r),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: .circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10.r,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
          border: .all(color: Colors.grey.shade100),
        ),
        child: Icon(icon, color: color, size: 26.sp),
      ),
    );
  }
}
