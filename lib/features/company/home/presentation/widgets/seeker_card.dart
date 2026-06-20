import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../users/user_info/data/models/user_info_model.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../manager/company_home_cubit.dart';

class SeekerCard extends StatelessWidget {
  final UserInfoModel seeker;
  final bool isSaved;

  const SeekerCard({super.key, required this.seeker, required this.isSaved});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: .only(bottom: 16.h),
      padding: .all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: .circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: seeker.avatarUrl != null && seeker.avatarUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: seeker.avatarUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CupertinoActivityIndicator(),
                          ),
                          errorWidget: (context, url, error) => Image.asset(
                            "assets/icons/play-store-icon-launcher.png",
                            fit: BoxFit.cover,
                          ),
                        )
                      : Image.asset(
                          "assets/icons/play-store-icon-launcher.png",
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              //
              SizedBox(width: 12.w),
              //
              // Name, Title, Location
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      seeker.name,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      seeker.jobTitle,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.grey.shade500,
                          size: 14.sp,
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            seeker.locationName,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Bookmark Icon
              GestureDetector(
                onTap: () {
                  context.read<CompanyHomeCubit>().toggleBookmark(
                    seeker.name,
                  ); // Using name as temp ID
                },
                child: Icon(
                  isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: isSaved
                      ? AppColors.primaryColor
                      : Colors.grey.shade400,
                  size: 26.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // Chips
          Row(
            children: [
              _buildChip(
                seeker.level,
                Colors.blue.shade50,
                Colors.blue.shade700,
              ),
              SizedBox(width: 8.w),
              _buildChip(
                seeker.typeOfWork,
                Colors.purple.shade50,
                Colors.purple.shade700,
              ),
              SizedBox(width: 8.w),
              _buildChip(
                seeker.jobCategory,
                Colors.orange.shade50,
                Colors.orange.shade800,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // Gamification Badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.star_rounded,
                  color: Colors.amber.shade600,
                  size: 20.sp,
                ),
                SizedBox(width: 6.w),
                Text(
                  "${seeker.totalPoints} Points",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, Color bgColor, Color textColor) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
