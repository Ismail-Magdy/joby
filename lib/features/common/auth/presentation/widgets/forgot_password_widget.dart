import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joby/core/helpers/extensions.dart';
import 'package:joby/core/routes/routes.dart';

class ForgotPasswordWidget extends StatelessWidget {
  const ForgotPasswordWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () => context.pushNamed(Routes.forgotPasswordScreen),
        child: Text(
          "Forgot Password?",
          style: TextStyle(color: Colors.grey.shade700, fontSize: 13.sp),
        ),
      ),
    );
  }
}
