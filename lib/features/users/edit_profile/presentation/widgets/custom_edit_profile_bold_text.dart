import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomEditProfileBoldText extends StatelessWidget {
  const CustomEditProfileBoldText({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontSize: 18.sp, fontWeight: .bold),
    );
  }
}
