import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joby/core/themes/app_colors.dart';
import 'package:joby/core/widgets/custom_app_bar_with_no_leading.dart';

class ProfileViewsScreen extends StatelessWidget {
  const ProfileViewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      //
      appBar: CustomAppBarWithNoLeading(text: "Profile Views"),
      //
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            Text(
              "COMING SOON !",
              style: TextStyle(
                color: AppColors.primaryColor,
                fontWeight: .bold,
                fontSize: 30.sp,
                fontFamily: "BrunoAceSC",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
