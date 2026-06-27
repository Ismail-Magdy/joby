import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:joby/core/helpers/extensions.dart';
import 'package:joby/core/themes/app_colors.dart';

class AboutHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String version;

  AboutHeaderDelegate({required this.version});

  @override
  double get maxExtent => 220.h;
  @override
  double get minExtent => 100.h;

  @override
  bool shouldRebuild(covariant AboutHeaderDelegate oldDelegate) =>
      version != oldDelegate.version;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    // 0.0 = fully expanded, 1.0 = fully collapsed
    final double t = min(1.0, shrinkOffset / (maxExtent - minExtent));
    final double statusBarH = MediaQuery.of(context).padding.top;
    final double screenW = MediaQuery.of(context).size.width;

    // --- Opacities ---
    final double textOpacity = max(0.0, 1.0 - t * 2.0); // Fades out early

    // --- Back Button Position ---
    final double backButtonX = 10.w;
    final double backExpandedY = statusBarH + 10.h;
    final double backCollapsedY =
        statusBarH + (minExtent - statusBarH) / 2 - 24.h;
    final double backY = backExpandedY + (backCollapsedY - backExpandedY) * t;

    // --- Logo Size and Position ---
    final double logoExpandedH = 58.h;
    final double logoCollapsedH = 34.h;
    final double logoH = logoExpandedH + (logoCollapsedH - logoExpandedH) * t;

    final double logoExpandedY = statusBarH + 50.h;
    final double logoCollapsedY =
        statusBarH + (minExtent - statusBarH) / 2 - logoCollapsedH / 2;
    final double logoY = logoExpandedY + (logoCollapsedY - logoExpandedY) * t;

    // --- Text Position ---
    final double textY = logoExpandedY + logoExpandedH + 10.h;

    // --- Version Position ---
    final double versionW = 80.w; // Approximate width
    final double versionExpandedX = screenW / 2 - versionW / 2;
    final double versionExpandedY = textY + 40.h;

    final double versionCollapsedX = screenW - versionW - 20.w;
    final double versionCollapsedY =
        statusBarH + (minExtent - statusBarH) / 2 - 14.h;

    final double versionX =
        versionExpandedX + (versionCollapsedX - versionExpandedX) * t;
    final double versionY =
        versionExpandedY + (versionCollapsedY - versionExpandedY) * t;

    // Background Gradient and BorderRadius
    final double borderRadius =
        35.r * (1 - t * 0.5); // Slightly reduces radius when collapsed

    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: .only(
          bottomLeft: .circular(borderRadius),
          bottomRight: .circular(borderRadius),
        ),
      ),
      child: Stack(
        children: [
          // Back Button
          Positioned(
            left: backButtonX,
            top: backY,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => context.pop(),
            ),
          ),
          // Logo
          Positioned(
            left: 0,
            right: 0, // Centered horizontally always
            top: logoY,
            child: Align(
              alignment: .center,
              child: SvgPicture.asset(
                "assets/svgs/joby_logo.svg",
                height: logoH,
                colorFilter: const .mode(Colors.white, .srcIn),
              ),
            ),
          ),
          // Subtext (Fades out)
          if (textOpacity > 0)
            Positioned(
              left: 0,
              right: 0,
              top: textY,
              child: Opacity(
                opacity: textOpacity,
                child: Align(
                  alignment: .center,
                  child: Text(
                    "Connecting Talent with Opportunity",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13.sp,
                    ),
                  ),
                ),
              ),
            ),
          // Version Badge
          Positioned(
            left: versionX,
            top: versionY,
            child: Container(
              padding: .symmetric(horizontal: 20.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: .circular(20.r),
              ),
              child: Text(
                version,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: .w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
