import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      "© 2026 Joby - Made in Egypt",
      style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade700),
    );
  }
}
