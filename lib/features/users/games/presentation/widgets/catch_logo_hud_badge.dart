import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joby/core/helpers/spacing.dart';

class CatchLogoHudBadge extends StatelessWidget {
  const CatchLogoHudBadge({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.white60,
            fontFamily: "BrunoAceSC",
          ),
        ),
        verticalSpace(2),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: .bold,
            color: color,
            fontFamily: "BrunoAceSC",
          ),
        ),
      ],
    );
  }
}
