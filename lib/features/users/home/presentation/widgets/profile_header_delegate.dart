import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ionicons/ionicons.dart';
import 'package:joby/core/helpers/spacing.dart';
import 'package:joby/core/themes/app_colors.dart';
import 'package:joby/features/users/home/presentation/widgets/full_screen_avatar_dialog.dart';

class ProfileHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String userId;
  final String? avatarUrl;
  final String title;
  final String name;
  final String jobTitle;
  final VoidCallback? onManagerTap;
  final VoidCallback? onEditTap;
  final bool showBackButton;
  final Widget? trailingAction;

  ProfileHeaderDelegate({
    required this.userId,
    required this.avatarUrl,
    required this.title,
    required this.name,
    required this.jobTitle,
    this.onManagerTap,
    this.onEditTap,
    this.showBackButton = false,
    this.trailingAction,
  });

  @override
  double get maxExtent => 160.h;
  @override
  double get minExtent => 120.h;

  @override
  bool shouldRebuild(covariant ProfileHeaderDelegate oldDelegate) =>
      avatarUrl != oldDelegate.avatarUrl ||
      title != oldDelegate.title ||
      name != oldDelegate.name ||
      jobTitle != oldDelegate.jobTitle;

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

    // Opacities
    final double fadeOpacity = (1.0 - (shrinkOffset / (maxExtent - minExtent)))
        .clamp(0.0, 1.0);
    final double expandedOpacity = max(0.0, 1.0 - t * 2.0); // Fades out early
    final double collapsedOpacity = max(0.0, (t - 0.5) * 2.0); // Fades in late

    // Avatar sizes
    final double maxRadius = 60.r;
    final double minRadius = 25.r;
    final double avatarRadius = maxRadius - (maxRadius - minRadius) * t;

    // Avatar position
    // Expanded: centered horizontally, at the bottom of the blue area
    final double expandedAvatarCX = screenW / 2;
    final double expandedAvatarCY = maxExtent - maxRadius * 0.2;
    // Collapsed: left side
    final double collapsedAvatarCX = 20.w + minRadius;
    final double collapsedAvatarCY = statusBarH + (minExtent - statusBarH) / 2;
    // Lerp
    final double avatarCX =
        expandedAvatarCX + (collapsedAvatarCX - expandedAvatarCX) * t;
    final double avatarCY =
        expandedAvatarCY + (collapsedAvatarCY - expandedAvatarCY) * t;

    // Title "My Profile" position (only visible when expanded)
    final double titleTop = statusBarH + 15.h;

    // Name & Job Title position (only visible when collapsed)
    final double infoLeft = collapsedAvatarCX + minRadius + 15.w;
    final double infoTop = statusBarH + (minExtent - statusBarH) / 2 - 20.h;

    // Icons position
    final double iconsExpandedTop = statusBarH + 54.h;
    final double iconsCollapsedTop =
        statusBarH + (minExtent - statusBarH) / 2 - 11.h;

    // Manager icon
    final double managerX = 30.w;

    // Edit icon
    final double editExpandedX = screenW - 30.w - 22.w;
    final double editCollapsedX = screenW - 20.w - 22.w;
    final double editX = editExpandedX + (editCollapsedX - editExpandedX) * t;
    final double editY =
        iconsExpandedTop + (iconsCollapsedTop - iconsExpandedTop) * t;

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

          // Title "My Profile" - Fades out
          if (expandedOpacity > 0)
            Positioned(
              top: titleTop,
              left: 0,
              right: 0,
              child: Opacity(
                opacity: expandedOpacity,
                child: Text(
                  title,
                  textAlign: .center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: .bold,
                    fontFamily: "BrunoAceSC",
                  ),
                ),
              ),
            ),

          // Name and Job Title - Fades in
          if (collapsedOpacity > 0)
            Positioned(
              top: infoTop,
              left: infoLeft,
              child: Opacity(
                opacity: collapsedOpacity,
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: .bold,
                      ),
                    ),
                    verticalSpace(3),
                    Text(
                      jobTitle,
                      style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                    ),
                  ],
                ),
              ),
            ),

          // Manager icon - Fades out
          if (expandedOpacity > 0 && onManagerTap != null)
            Positioned(
              top: iconsExpandedTop,
              left: managerX,
              child: Opacity(
                opacity: expandedOpacity,
                child: GestureDetector(
                  onTap: onManagerTap,
                  child: SvgPicture.asset(
                    "assets/svgs/manager.svg",
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                    height: 22.h,
                  ),
                ),
              ),
            ),

          // Edit icon - Stays visible, moves
          if (onEditTap != null)
            Positioned(
              top: editY,
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

          // Avatar - Moves and scales
          Positioned(
            left: avatarCX - avatarRadius,
            top: avatarCY - avatarRadius,
            child: GestureDetector(
              onTap: () {
                showFullScreenAvatarDialog(context, avatarUrl, userId);
              },
              child: Hero(
                tag: "profile_avatar",
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
            ),
          ),

          // Back button and Trailing action — LAST so it's on top for taps
          if (showBackButton || trailingAction != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: IgnorePointer(
                  ignoring: fadeOpacity <= 0.0,
                  child: Opacity(
                    opacity: fadeOpacity,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 10.h,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (showBackButton)
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.white,
                              ),
                              onPressed: () => Navigator.pop(context),
                            )
                          else
                            const SizedBox.shrink(),
                          if (trailingAction != null)
                            SizedBox(
                              width: 48.w,
                              height: 48.h,
                              child: Center(child: trailingAction!),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          //
        ],
      ),
    );
  }
}
