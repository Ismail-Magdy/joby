import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomGoogleButton extends StatelessWidget {
  const CustomGoogleButton({
    super.key,
    required this.onPressed,
    required this.text,
  });
  final void Function()? onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: .infinity,
      height: 55.h,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: BorderSide(color: Colors.grey.shade300, width: 1),
          shape: RoundedRectangleBorder(borderRadius: .circular(14.r)),
        ),
        icon: const FaIcon(
          FontAwesomeIcons.google,
          color: Colors.black,
          size: 20,
        ),
        label: Text(
          text,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: .w600,
            color: Colors.black87,
            fontFamily: "BrunoAceSC",
          ),
        ),
      ),
    );
  }
}
