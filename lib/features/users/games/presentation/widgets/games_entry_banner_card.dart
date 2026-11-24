import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../../core/helpers/extensions.dart';
import '../../../../../core/helpers/spacing.dart';
import '../../../../../core/routes/routes.dart';
import '../../../../../core/themes/app_colors.dart';

class GamesEntryBannerCard extends StatelessWidget {
  const GamesEntryBannerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: .symmetric(horizontal: 24.w, vertical: 10.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), AppColors.primaryColor],
          begin: .topLeft,
          end: .bottomRight,
        ),
        borderRadius: .circular(22.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.3),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: .circular(22.r),
          onTap: () => context.pushNamed(Routes.gamesHubScreen),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
            child: Row(
              children: [
                // Text side
                Expanded(
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      // Badge
                      Container(
                        padding: .symmetric(horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.2),
                          borderRadius: .circular(8.r),
                          border: .all(
                            color: Colors.amber.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: .min,
                          children: [
                            Icon(
                              Icons.bolt_rounded,
                              color: Colors.amber,
                              size: 12.sp,
                            ),
                            horizontalSpace(4),
                            Text(
                              "JOBY ARCADE",
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: .bold,
                                color: Colors.amber,
                                fontFamily: "BrunoAceSC",
                              ),
                            ),
                          ],
                        ),
                      ),
                      verticalSpace(8),
                      // Title
                      Text(
                        "Play Mini Games",
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: .bold,
                          color: Colors.white,
                          fontFamily: "BrunoAceSC",
                        ),
                      ),
                      verticalSpace(4),
                      // Subtitle
                      Text(
                        "Earn Up to 185 Points Daily",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                horizontalSpace(12),
                // Visual Right side (Logo & Play Button)
                Column(
                  children: [
                    Container(
                      width: 50.w,
                      height: 50.w,
                      padding: .all(10.r),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: .circle,
                        border: .all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: SvgPicture.asset(
                        "assets/svgs/joby_logo.svg",
                        colorFilter: const .mode(Colors.white, .srcIn),
                      ),
                    ),
                    verticalSpace(6),
                    Container(
                      padding: .symmetric(horizontal: 10.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: .circular(10.r),
                      ),
                      child: Text(
                        "PLAY",
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: .bold,
                          color: AppColors.primaryColor,
                          fontFamily: "BrunoAceSC",
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
