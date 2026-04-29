import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ionicons/ionicons.dart';
import 'package:joby/core/themes/app_colors.dart';

class ProfileHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String? avatarUrl;
  final String title;
  final VoidCallback onManagerTap;
  final VoidCallback onEditTap;

  ProfileHeaderDelegate({
    required this.avatarUrl,
    required this.title,
    required this.onManagerTap,
    required this.onEditTap,
  });

  @override
  double get maxExtent => 170.h;
  @override
  double get minExtent => 125.h;

  @override
  bool shouldRebuild(covariant ProfileHeaderDelegate oldDelegate) =>
      avatarUrl != oldDelegate.avatarUrl || title != oldDelegate.title;

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
    final double currentHeight = max(maxExtent - shrinkOffset, minExtent);

    // --- Avatar sizes ---
    final double maxRadius = 60.r;
    final double minRadius = 25.r;
    final double avatarRadius = maxRadius - (maxRadius - minRadius) * t;

    // --- Avatar position ---
    // Expanded: centered horizontally, at the bottom of the blue area
    final double expandedAvatarCX = screenW / 2;
    final double expandedAvatarCY = maxExtent - maxRadius * 0.2;
    // Collapsed: top-right corner
    final double collapsedAvatarCX = screenW - 22.w - minRadius;
    final double collapsedAvatarCY = statusBarH + 20.h + minRadius;
    // Lerp
    final double avatarCX =
        expandedAvatarCX + (collapsedAvatarCX - expandedAvatarCX) * t;
    final double avatarCY =
        expandedAvatarCY + (collapsedAvatarCY - expandedAvatarCY) * t;

    //  Title position
    // Expanded: centered   |   Collapsed: left
    final double titleExpandedLeft = 0;
    final double titleCollapsedLeft = 20.w;
    final double titleLeft =
        titleExpandedLeft + (titleCollapsedLeft - titleExpandedLeft) * t;

    //  Icons position
    // Expanded: icon1 far-left, icon2 far-right (spread across screen)
    // Collapsed: both grouped left
    final double iconsTopY = statusBarH + 54.h;
    // Manager icon
    final double managerExpandedX = 30.w;
    final double managerCollapsedX = 20.w;
    final double managerX =
        managerExpandedX + (managerCollapsedX - managerExpandedX) * t;
    // Edit icon
    final double editExpandedX = screenW - 30.w - 22.w;
    final double editCollapsedX = 20.w + 22.h + 18.w; // after manager + spacing
    final double editX = editExpandedX + (editCollapsedX - editExpandedX) * t;

    //  Blue background
    final double borderRadius = 24.r * (1 - t * 0.3);
    // Bottom margin grows when collapsed
    final double bottomMargin = 6.h * t;

    return SizedBox(
      height: currentHeight,
      child: Stack(
        clipBehavior: .none,
        children: [
          // Blue background with rounded bottom corners + margin
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: bottomMargin,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: .only(
                  bottomLeft: .circular(borderRadius),
                  bottomRight: .circular(borderRadius),
                ),
              ),
            ),
          ),

          // Title "My Profile"
          // Expanded: centered across full width | Collapsed: left-aligned
          Positioned(
            top: statusBarH + 15.h,
            left: titleLeft,
            right: 0,
            child: Text(
              title,
              textAlign: t < 0.5 ? .center : .left,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: .bold,
                fontFamily: "BrunoAceSC",
              ),
            ),
          ),

          // Manager icon - animates from far-left to grouped-left
          Positioned(
            top: iconsTopY,
            left: managerX,
            child: GestureDetector(
              onTap: onManagerTap,
              child: SvgPicture.asset(
                "assets/svgs/manager.svg",
                colorFilter: const .mode(Colors.white, .srcIn),
                height: 22.h,
              ),
            ),
          ),

          // Edit icon - animates from far-right to grouped-left
          Positioned(
            top: iconsTopY,
            left: editX,
            child: GestureDetector(
              onTap: onEditTap,
              child: SvgPicture.asset(
                "assets/svgs/pen.svg",
                colorFilter: const .mode(Colors.white, .srcIn),
                height: 22.h,
              ),
            ),
          ),

          // Avatar - animates from center-bottom to top-right
          Positioned(
            left: avatarCX - avatarRadius,
            top: avatarCY - avatarRadius,
            child: Container(
              padding: .all(2.r),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: .circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: avatarRadius,
                backgroundColor: Colors.grey.shade100,
                backgroundImage: avatarUrl != null
                    ? NetworkImage(avatarUrl!)
                    : null,
                child: avatarUrl == null
                    ? Icon(
                        Ionicons.person,
                        size: avatarRadius * 0.7,
                        color: Colors.grey.shade400,
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
