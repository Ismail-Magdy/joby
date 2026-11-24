import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../core/helpers/spacing.dart';
import '../../../../../core/themes/app_colors.dart';

class CustomHeadSection extends StatelessWidget {
  const CustomHeadSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          verticalSpace(18),
          //
          SvgPicture.asset(
            "assets/svgs/feedback.svg",
            colorFilter: .mode(AppColors.primaryColor, .srcIn),
            height: 45.h,
          ),
          //
          verticalSpace(18),
          //
          Text(
            "Your Voice Matters",
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: .bold,
              color: Colors.black87,
              fontFamily: "BrunoAceSC",
            ),
          ),
          //
          verticalSpace(10),
          //
          Text(
            "We Read Every Suggestion.\nHelp Us Make Joby Even Better",
            textAlign: .center,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade600,
              height: 1.55,
            ),
          ),
          //
        ],
      ),
    );
  }
}
