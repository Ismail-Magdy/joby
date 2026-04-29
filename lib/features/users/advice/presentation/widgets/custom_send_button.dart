import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../core/themes/app_colors.dart';

class CustomSendButton extends StatelessWidget {
  const CustomSendButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  final void Function()? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: .infinity,
      height: 56.h,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          disabledBackgroundColor: AppColors.primaryColor.withValues(
            alpha: 0.6,
          ),
          shape: RoundedRectangleBorder(borderRadius: .circular(16.r)),
          elevation: 0,
        ),
        icon: isLoading
            ? CupertinoActivityIndicator(
                color: Colors.white,
              )
            : SvgPicture.asset(
                "assets/svgs/send.svg",
                colorFilter: .mode(Colors.white, .srcIn),
                height: 25.h,
              ),

        label: Text(
          isLoading ? "Sending..." : "Send Feedback",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: .bold,
            fontFamily: "BrunoAceSC",
          ),
        ),
      ),
    );
  }
}
