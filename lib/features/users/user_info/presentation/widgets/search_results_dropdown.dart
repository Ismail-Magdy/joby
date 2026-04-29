import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joby/core/themes/app_colors.dart';

class SearchResultsDropdown extends StatelessWidget {
  const SearchResultsDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: .all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: .circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: CupertinoActivityIndicator(color: AppColors.primaryColor),
      ),
    );
  }
}
