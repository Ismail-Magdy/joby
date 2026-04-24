import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:joby/core/helpers/spacing.dart';

class UserTypeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const UserTypeCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: .all(20.r),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF096DCA).withValues(alpha: 0.08)
              : Colors.white,
          border: .all(
            color: isSelected ? const Color(0xFF096DCA) : Colors.grey.shade300,
            width: isSelected ? 2.w : 1.w,
          ),
          borderRadius: .circular(16.r),
        ),
        child: Row(
          children: [
            Container(
              padding: .all(16.r),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF096DCA)
                    : Colors.grey.shade100,
                shape: .circle,
              ),
              child: FaIcon(
                icon,
                color: isSelected ? Colors.white : Colors.grey.shade500,
                size: 24.sp,
              ),
            ),
            //
            horizontalSpace(16),
            //
            Expanded(
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  // Title
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: .bold,
                      fontFamily: "BrunoAceSC",
                      color: isSelected
                          ? const Color(0xFF096DCA)
                          : Colors.black87,
                    ),
                  ),
                  //
                  verticalSpace(6),
                  // Sub Title
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  //
                ],
              ),
            ),
            //
            if (isSelected)
              // True Icon
              Icon(
                Icons.check_circle,
                color: const Color(0xFF096DCA),
                size: 24.sp,
              ),
            //
          ],
        ),
      ),
    );
  }
}
