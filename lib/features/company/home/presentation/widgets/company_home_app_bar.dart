import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../../core/themes/app_colors.dart';

class CompanyHomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CompanyHomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _AppBarClipper(),
      child: Container(
        height: preferredSize.height,
        color: AppColors.primaryColor,
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Notification Icon
              IconButton(
                icon: Icon(Icons.notifications_outlined, color: Colors.white, size: 28.sp),
                onPressed: () {
                  // TODO: Navigate to notifications
                },
              ),
              // App Logo
              SvgPicture.asset(
                "assets/svgs/joby_logo.svg",
                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                height: 30.h,
              ),
              // Profile Menu Icon
              IconButton(
                icon: Icon(Icons.menu, color: Colors.white, size: 28.sp),
                onPressed: () {
                  // TODO: Open drawer or profile menu
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(100.h);
}

class _AppBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 30);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 30);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
