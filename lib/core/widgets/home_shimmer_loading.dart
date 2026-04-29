import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joby/core/helpers/spacing.dart';
import 'package:joby/core/themes/app_colors.dart';
import 'package:joby/core/widgets/shimmer_widgets.dart';

/// Shimmer loading placeholder for the User Home (Profile) screen.
/// Updated to match the new animated header layout.
class HomeShimmerLoading extends StatelessWidget {
  const HomeShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final double statusBarH = MediaQuery.of(context).padding.top;
    final double screenW = MediaQuery.of(context).size.width;

    return ShimmerWrapper(
      child: Column(
        children: [
          // Header Shimmer
          SizedBox(
            height: 210.h,
            child: Stack(
              clipBehavior: .none,
              children: [
                // Blue background placeholder
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.1),
                      borderRadius: .only(
                        bottomLeft: .circular(24.r),
                        bottomRight: .circular(24.r),
                      ),
                    ),
                  ),
                ),
                // Title placeholder (Centered)
                Positioned(
                  top: statusBarH + 10.h,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ShimmerBox(
                      width: 120.w,
                      height: 20.h,
                      borderRadius: 8.r,
                    ),
                  ),
                ),
                // Icons row placeholder
                Positioned(
                  top: statusBarH + 44.h,
                  left: 30.w,
                  right: 30.w,
                  child: Row(
                    mainAxisAlignment: .spaceBetween,
                    children: [
                      ShimmerBox(width: 22.w, height: 22.h, borderRadius: 6.r),
                      ShimmerBox(width: 22.w, height: 22.h, borderRadius: 6.r),
                    ],
                  ),
                ),
                // Avatar placeholder (Centered bottom)
                Positioned(
                  left: (screenW / 2) - 50.r,
                  top: 210.h - 50.r * 1.2,
                  child: Container(
                    padding: .all(2.r),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: .circle,
                    ),
                    child: ShimmerBox.circle(size: 100.r),
                  ),
                ),
              ],
            ),
          ),

          // Body content shimmer
          Expanded(
            child: SingleChildScrollView(
              padding: .only(bottom: 120.h),
              child: Column(
                children: [
                  verticalSpace(65),
                  // Name
                  ShimmerBox(width: 180.w, height: 22.h, borderRadius: 10.r),
                  verticalSpace(10),
                  // Job Title
                  ShimmerBox(width: 140.w, height: 16.h, borderRadius: 8.r),
                  verticalSpace(25),
                  // Badges
                  Row(
                    mainAxisAlignment: .center,
                    children: [
                      ShimmerBox(width: 80.w, height: 36.h, borderRadius: 20.r),
                      horizontalSpace(15),
                      ShimmerBox(
                        width: 100.w,
                        height: 36.h,
                        borderRadius: 20.r,
                      ),
                      horizontalSpace(15),
                      ShimmerBox(width: 80.w, height: 36.h, borderRadius: 20.r),
                    ],
                  ),
                  verticalSpace(50),
                  // Social Icons
                  Row(
                    mainAxisAlignment: .center,
                    children: [
                      ShimmerBox.circle(size: 46.r),
                      horizontalSpace(20),
                      ShimmerBox.circle(size: 46.r),
                      horizontalSpace(20),
                      ShimmerBox.circle(size: 46.r),
                    ],
                  ),
                  verticalSpace(60),
                  // CV Card
                  Padding(
                    padding: .symmetric(horizontal: 24.w),
                    child: ShimmerBox(
                      width: double.infinity,
                      height: 70.h,
                      borderRadius: 16.r,
                    ),
                  ),
                  verticalSpace(30),
                  // Map Shimmer
                  Padding(
                    padding: .symmetric(horizontal: 24.w),
                    child: ShimmerBox(
                      width: .infinity,
                      height: 200.h,
                      borderRadius: 16.r,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
