import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joby/core/helpers/spacing.dart';
import 'package:joby/core/themes/app_colors.dart';
import 'package:joby/features/company/home/presentation/widgets/preview_chip_widget.dart';
import 'package:joby/features/users/user_info/data/models/user_info_model.dart';

class SeekerPreviewOverlay extends StatefulWidget {
  final UserInfoModel seeker;
  final VoidCallback onDismiss;

  const SeekerPreviewOverlay({
    super.key,
    required this.seeker,
    required this.onDismiss,
  });

  @override
  State<SeekerPreviewOverlay> createState() => SeekerPreviewOverlayState();
}

class SeekerPreviewOverlayState extends State<SeekerPreviewOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.addListener(() {
      if (mounted) setState(() {});
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _capitalize(String text) {
    return text
        .trim()
        .split(RegExp(r"\s+"))
        .map((word) {
          if (word.isEmpty) return "";
          return "${word[0].toUpperCase()}${word.substring(1).toLowerCase()}";
        })
        .join(" ");
  }

  @override
  Widget build(BuildContext context) {
    final seeker = widget.seeker;
    final screenSize = MediaQuery.of(context).size;

    final double scaleValue = _scaleAnimation.value;
    final double fadeValue = _fadeAnimation.value;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Blurred + darkened background
          Positioned.fill(
            child: Opacity(
              opacity: fadeValue,
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 8.0 * fadeValue,
                  sigmaY: 8.0 * fadeValue,
                ),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.4 * fadeValue),
                ),
              ),
            ),
          ),
          //
          // Preview Card
          Center(
            child: Transform.scale(
              scale: scaleValue,
              child: Opacity(
                opacity: fadeValue,
                child: Container(
                  width: screenSize.width * 0.85,
                  margin: .symmetric(horizontal: 20.w),
                  padding: .all(24.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: .circular(28.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withValues(alpha: 0.15),
                        blurRadius: 30.r,
                        spreadRadius: 2,
                        offset: const Offset(0, 10),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 40,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: .min,
                    children: [
                      // Top accent bar
                      Container(
                        width: 40.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withValues(alpha: 0.3),
                          borderRadius: .circular(2.r),
                        ),
                      ),
                      //
                      verticalSpace(20),
                      //
                      // Avatar
                      Container(
                        width: 90.w,
                        height: 90.w,
                        decoration: BoxDecoration(
                          shape: .circle,
                          border: .all(
                            color: AppColors.primaryColor.withValues(
                              alpha: 0.2,
                            ),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryColor.withValues(
                                alpha: 0.15,
                              ),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child:
                              seeker.avatarUrl != null &&
                                  seeker.avatarUrl!.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: seeker.avatarUrl!,
                                  fit: .cover,
                                  placeholder: (context, url) =>
                                      Container(color: Colors.grey.shade100),
                                  errorWidget: (context, url, error) => Image.asset(
                                    "assets/icons/play-store-icon-launcher.png",
                                    fit: .cover,
                                  ),
                                )
                              : Image.asset(
                                  "assets/icons/play-store-icon-launcher.png",
                                  fit: .cover,
                                ),
                        ),
                      ),
                      //
                      verticalSpace(16),
                      //
                      // Name
                      Text(
                        _capitalize(seeker.displayShortName),
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: .bold,
                          color: Colors.black87,
                        ),
                        textAlign: .center,
                        maxLines: 1,
                        overflow: .ellipsis,
                      ),
                      //
                      verticalSpace(4),
                      //
                      // Job Title
                      Text(
                        _capitalize(seeker.jobTitle),
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.primaryColor,
                          fontWeight: .w600,
                        ),
                        textAlign: .center,
                        maxLines: 1,
                        overflow: .ellipsis,
                      ),
                      //
                      verticalSpace(16),
                      //
                      // Divider
                      Container(
                        height: 1,
                        margin: .symmetric(horizontal: 16.w),
                        color: Colors.grey.shade200,
                      ),
                      //
                      verticalSpace(16),
                      //
                      // Info Row: Level + Points
                      Row(
                        mainAxisAlignment: .center,
                        children: [
                          // Level chip
                          if (seeker.level.isNotEmpty)
                            PreviewChipWidget(
                              icon: Icons.trending_up_rounded,
                              label: _capitalize(seeker.level),
                            ),
                          //
                          if (seeker.level.isNotEmpty) SizedBox(width: 12.w),
                          // Points chip
                          PreviewChipWidget(
                            icon: Icons.stars_rounded,
                            label: "${seeker.totalPoints} pts",
                            isPrimary: true,
                          ),
                        ],
                      ),
                      //
                      verticalSpace(12),
                      //
                      // Location
                      if (seeker.locationName.isNotEmpty)
                        //
                        Row(
                          mainAxisAlignment: .center,
                          mainAxisSize: .min,
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              color: Colors.grey.shade500,
                              size: 14.sp,
                            ),
                            //
                            horizontalSpace(4),
                            //
                            Flexible(
                              child: Text(
                                seeker.locationName,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey.shade600,
                                ),
                                maxLines: 1,
                                overflow: .ellipsis,
                              ),
                            ),
                          ],
                        ),
                      //
                      verticalSpace(8),
                      //
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 640
