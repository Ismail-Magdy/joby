import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:joby/core/themes/app_colors.dart';
import 'package:joby/features/company/home/presentation/widgets/search_filter_bar.dart';

class FixedHeaderCompanyHome extends StatelessWidget {
  const FixedHeaderCompanyHome({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150.h,
      child: Stack(
        clipBehavior: .none,
        children: [
          // AppBar
          Container(
            height: 125.h,
            width: .infinity,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: .only(
                bottomLeft: .circular(20.r),
                bottomRight: .circular(20.r),
              ),
            ),
            child: Center(
              child: SvgPicture.asset(
                "assets/svgs/joby_logo.svg",
                height: 60.h,
                colorFilter: const .mode(Colors.white, .srcIn),
              ),
            ),
          ),
          // Search Filter Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: const SearchFilterBar(),
          ),
          //
        ],
      ),
    );
  }
}
