import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joby/core/helpers/spacing.dart';
import 'package:latlong2/latlong.dart';

class LocationMapSection extends StatelessWidget {
  const LocationMapSection({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.locationName,
  });
  final double latitude;
  final double longitude;
  final String locationName;

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
          Container(
            height: 200.h,
            width: .infinity,
            //
            decoration: BoxDecoration(
              borderRadius: .circular(16.r),
              border: .all(color: Colors.grey.shade300),
            ),
            //
            child: ClipRRect(
              borderRadius: .circular(16.r),
              child: Stack(
                children: [
                  // Loading background
                  Container(
                    color: Colors.grey.shade100,
                    child: const Center(child: CupertinoActivityIndicator()),
                  ),
                  //
                  FlutterMap(
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
                  //
                  Center(
                    child: Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 40.sp,
                    ),
                  ),
                  //
                  Positioned(
                    bottom: 10.h,
                    left: 10.w,
                    right: 10.w,
                    child: Container(
                      padding: .symmetric(horizontal: 12.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: .circular(8.r),
                      ),
                      child: Text(
                        locationName,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: .w600,
                          color: Colors.black87,
                        ),
                        textAlign: .center,
                      ),
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
    );
    //
  }
}
