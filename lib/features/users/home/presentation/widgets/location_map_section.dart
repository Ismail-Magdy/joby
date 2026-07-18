import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joby/core/helpers/spacing.dart';
import 'package:latlong2/latlong.dart';
import 'package:joby/core/themes/app_colors.dart';

class LocationMapSection extends StatelessWidget {
  const LocationMapSection({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.locationName,
    this.onEditTap,
  });
  final double latitude;
  final double longitude;
  final String locationName;
  final VoidCallback? onEditTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: .symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          //
          Text(
            "Location",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: .bold,
              color: Colors.black87,
            ),
          ),
          //
          verticalSpace(15),
          //
          Row(
            children: [
              //
              Icon(
                Icons.location_on,
                color: AppColors.primaryColor,
                size: 24.sp,
              ),
              //
              horizontalSpace(8),
              //
              Expanded(
                child: Text(
                  locationName,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: .w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              //
            ],
          ),
          //
          verticalSpace(15),
          //
          GestureDetector(
            onTap: onEditTap,
            child: Container(
              height: 250.h,
              width: .infinity,
              decoration: BoxDecoration(
                borderRadius: .circular(16.r),
                border: .all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: .circular(16.r),
                child: Stack(
                  alignment: .center,
                  children: [
                    // Loading background
                    Container(
                      color: Colors.grey.shade100,
                      child: const Center(child: CupertinoActivityIndicator()),
                    ),
                    // Map Preview (non-interactive)
                    AbsorbPointer(
                      absorbing:
                          onEditTap != null, // Absorb touches if tappable
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: LatLng(latitude, longitude),
                          initialZoom: 14.0,
                          interactionOptions: const InteractionOptions(
                            flags: InteractiveFlag.none,
                          ),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                            userAgentPackageName: 'com.example.joby',
                          ),
                        ],
                      ),
                    ),
                    //
                    Icon(Icons.location_pin, color: Colors.red, size: 40.sp),
                    //
                    if (onEditTap != null)
                      //
                      Positioned(
                        bottom: 10.h,
                        right: 10.w,
                        child: Container(
                          padding: .symmetric(horizontal: 12.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: .circular(20.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: .min,
                            children: [
                              //
                              Icon(
                                Icons.edit_location_alt,
                                color: Colors.white,
                                size: 16.sp,
                              ),
                              //
                              horizontalSpace(4),
                              //
                              Text(
                                "Change",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  fontWeight: .w600,
                                ),
                              ),
                              //
                            ],
                          ),
                        ),
                      ),
                    //
                  ],
                ),
              ),
            ),
          ),
          //
        ],
      ),
    );
    //
  }
}
