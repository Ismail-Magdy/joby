import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joby/core/helpers/extensions.dart';
import 'package:joby/core/themes/app_colors.dart';

class CompanyViewScreen extends StatelessWidget {
  const CompanyViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      //
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          "Company View",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20.sp,
            fontWeight: .bold,
            fontFamily: "BrunoAceSC",
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
      ),
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
