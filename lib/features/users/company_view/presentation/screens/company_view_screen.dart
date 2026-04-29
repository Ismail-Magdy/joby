import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joby/core/themes/app_colors.dart';
import 'package:joby/core/widgets/custom_app_bar.dart';

class CompanyViewScreen extends StatelessWidget {
  const CompanyViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      //
      appBar: CustomAppBar(text: "Company View"),
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
