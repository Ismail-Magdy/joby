import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joby/core/helpers/spacing.dart';
import 'package:joby/core/themes/app_colors.dart';
import 'package:latlong2/latlong.dart';

class StepFourContent extends StatelessWidget {
  const StepFourContent({
    super.key,
    required this.locationName,
    required this.isLoadingLocation,
    required this.onTap,
    required this.mapController,
    required this.latitude,
    required this.longitude,
  });
  final String locationName;
  final bool isLoadingLocation;
  final void Function() onTap;
  final MapController mapController;
  final double latitude;
  final double longitude;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //
        verticalSpace(10),
        //
        Row(
          children: [
            Icon(Icons.location_on, color: AppColors.primaryColor, size: 24.sp),
            //
            horizontalSpace(8),
            // Location Name
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
            if (isLoadingLocation)
              CupertinoActivityIndicator(color: AppColors.primaryColor),
          ],
        ),
        //
        verticalSpace(15),
        //
        // Tappable Map Preview
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 250.h,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Map Preview (non-interactive)
                  AbsorbPointer(
                    child: FlutterMap(
                      mapController: mapController,
                      options: MapOptions(
                        initialCenter: LatLng(latitude, longitude),
                        initialZoom: 14.0,
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
                  // "Tap to change" overlay
                  Positioned(
                    bottom: 10.h,
                    right: 10.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.edit_location_alt,
                            color: Colors.white,
                            size: 16.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            "Change",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        //
      ],
    );
  }
}
