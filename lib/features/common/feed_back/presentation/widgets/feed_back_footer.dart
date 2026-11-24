import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FeedBackFooter extends StatelessWidget {
  const FeedBackFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Your Feedback Will Be Sent Directly to Our Team",
        style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade400),
        textAlign: .center,
      ),
    );
  }
}
