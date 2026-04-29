import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joby/core/helpers/spacing.dart';
import 'package:joby/core/themes/app_colors.dart';

class LocationFooterWidget extends StatelessWidget {
  const LocationFooterWidget({
    super.key,
    required this.isLoadingLocation,
    required this.locationName,
    required this.onPressed,
  });
  final String locationName;
  final bool isLoadingLocation;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: .fromLTRB(20.w, 16.h, 20.w, 30.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: .vertical(top: .circular(24.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: .min,
        children: [
          // Location Info Row
          Row(
            children: [
              Container(
                padding: .all(10.r),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: .circular(12.r),
                ),
                child: Icon(
                  Icons.location_on,
                  color: AppColors.primaryColor,
                  size: 22.sp,
                ),
              ),
              //
              horizontalSpace(12),
              //
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      "Selected Location",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    verticalSpace(2),
                    isLoadingLocation
                        ? CupertinoActivityIndicator(
                            color: AppColors.primaryColor,
                          )
                        : Text(
                            locationName,
                            maxLines: 2,
                            overflow: .ellipsis,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: .w600,
                              color: Colors.black87,
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
          //
          verticalSpace(16),
          //
          // Confirm Button
          SizedBox(
            width: .infinity,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: .symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(borderRadius: .circular(14.r)),
                elevation: 0,
              ),
              child: Text(
                "Confirm Location",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: .bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
