import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ForgotPasswordWidget extends StatelessWidget {
  const ForgotPasswordWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: .centerRight,
      child: TextButton(
        onPressed: () {
          // TODO: ADD Forgot Password
        },
        child: Text(
          "Forgot Password? (will work soon)",
          style: TextStyle(color: Colors.grey.shade700, fontSize: 13.sp),
        ),
      ),
    );
  }
}
