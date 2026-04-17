import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AdviceFooter extends StatelessWidget {
  const AdviceFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Your default email app will open with the message pre filled",
        style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade400),
        textAlign: .center,
      ),
    );
  }
}
