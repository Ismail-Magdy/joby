import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joby/core/helpers/spacing.dart';
import 'package:joby/core/widgets/shimmer_widgets.dart';
import '../../../features/users/home/presentation/widgets/curve_painter.dart';

/// Shimmer loading placeholder for the User Home (Profile) screen.
///
/// Mirrors the actual profile layout:
/// header curve → avatar → name → job title → badges → social icons → CV card.
class HomeShimmerLoading extends StatelessWidget {
  const HomeShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrapper(
      child: SingleChildScrollView(
        padding: .only(bottom: 120.h),
        child: Column(
          children: [
            //
            //  Header (Curve + App Bar + Avatar)
            Stack(
              clipBehavior: .none,
              alignment: .center,
              children: [
                // Curve background
                CustomPaint(
                  size: Size(.infinity, 120.h),
                  painter: CurvePainter(),
                ),
                //
                // Fake app bar row
                Positioned(
                  top: 40.h,
                  left: 20.w,
                  right: 20.w,
                  child: Row(
                    mainAxisAlignment: .spaceBetween,
                    children: [
                      ShimmerBox(width: 22.w, height: 22.h, borderRadius: 6.r),
                      ShimmerBox(width: 100.w, height: 18.h, borderRadius: 8.r),
                      ShimmerBox(width: 22.w, height: 22.h, borderRadius: 6.r),
                    ],
                  ),
                ),
                //
                // Avatar placeholder
                Positioned(
                  top: 80.h,
                  child: Container(
                    padding: .all(2.r),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: .circle,
                    ),
                    child: ShimmerBox.circle(size: 110.r),
                  ),
                ),
                //
              ],
            ),
            //
            verticalSpace(95),
            //
            //  Name
            ShimmerBox(width: 180.w, height: 22.h, borderRadius: 10),
            //
            verticalSpace(10),
            //
            //  Job Title
            ShimmerBox(width: 140.w, height: 16.h, borderRadius: 8),
            //
            verticalSpace(25),
            //
            //  Level & Work Type Badges
            Row(
              mainAxisAlignment: .center,
              children: [
                ShimmerBox(width: 100.w, height: 36.h, borderRadius: 20),
                horizontalSpace(30),
                ShimmerBox(width: 100.w, height: 36.h, borderRadius: 20),
              ],
            ),
            //
            verticalSpace(50),
            //
            //  Social Icons
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
            //
            verticalSpace(60),
            //
            //  CV Card
            Padding(
              padding: .symmetric(horizontal: 24.w),
              child: ShimmerBox(
                width: .infinity,
                height: 70.h,
                borderRadius: 16.r,
              ),
            ),
            //
          ],
        ),
      ),
    );
  }
}
// 118