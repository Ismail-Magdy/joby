import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:joby/core/themes/app_colors.dart';

class CustomAvatarWidget extends StatelessWidget {
  const CustomAvatarWidget({
    super.key,
    required this.backgroundImage,
    required this.child,
    required this.onTap,
    required this.icon,
  });
  final ImageProvider<Object>? backgroundImage;
  final Widget? child;
  final void Function()? onTap;
  final String icon;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: .bottomRight,
        children: [
          // Image
          CircleAvatar(
            radius: 50.r,
            backgroundColor: Colors.grey.shade100,
            backgroundImage: backgroundImage,
            child: child,
          ),
          //
          // Camera Icon - opens gallery
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: .all(8.r),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                shape: .circle,
                border: .all(color: Colors.white, width: 2),
              ),
              child: SvgPicture.asset(
                icon,
                colorFilter: .mode(Colors.white, .srcIn),
                height: 18.h,
              ),
            ),
          ),
          //
        ],
      ),
    );
  }
}
