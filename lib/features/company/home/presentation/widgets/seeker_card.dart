import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:joby/core/helpers/spacing.dart';
import 'package:like_button/like_button.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../../users/user_info/data/models/user_info_model.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../manager/company_home_cubit.dart';
import 'package:joby/features/company/home/presentation/screens/talent_details_screen.dart';

class SeekerCard extends StatefulWidget {
  final UserInfoModel seeker;
  final bool isSaved;
  final Future<bool> Function(bool isSaved)? onBookmarkTapOverride;

  const SeekerCard({
    super.key,
    required this.seeker,
    required this.isSaved,
    this.onBookmarkTapOverride,
  });

  @override
  State<SeekerCard> createState() => _SeekerCardState();
}

class _SeekerCardState extends State<SeekerCard> {
  late AudioPlayer audioPlayer;

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final seeker = widget.seeker;
    final isSaved = widget.isSaved;
    final onBookmarkTapOverride = widget.onBookmarkTapOverride;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TalentDetailsScreen(seeker: seeker),
          ),
        );
      },
      child: Container(
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
              crossAxisAlignment: .start,
              children: [
                // Avatar
                Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: BoxDecoration(
                    shape: .circle,
                    border: .all(
                      color: AppColors.primaryColor.withValues(alpha: 0.1),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child:
                        seeker.avatarUrl != null && seeker.avatarUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: seeker.avatarUrl!,
                            fit: .cover,
                            placeholder: (context, url) => const Center(
                              child: CupertinoActivityIndicator(),
                            ),
                            errorWidget: (context, url, error) => Image.asset(
                              "assets/icons/play-store-icon-launcher.png",
                              fit: .cover,
                            ),
                          )
                        : Image.asset(
                            "assets/icons/play-store-icon-launcher.png",
                            fit: .cover,
                          ),
                  ),
                ),
                //
                horizontalSpace(12.w),
                //
                Expanded(
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      // Name
                      Text(
                        seeker.name
                            .trim()
                            .split(RegExp(r"\s+"))
                            .take(2)
                            .map((word) {
                              if (word.isEmpty) return "";
                              return "${word[0].toUpperCase()}${word.substring(1).toLowerCase()}";
                            })
                            .join(" "),
                        style: TextStyle(fontSize: 16.sp, fontWeight: .bold),
                        maxLines: 1,
                        overflow: .ellipsis,
                      ),
                      //
                      verticalSpace(4.h),
                      // Job Title
                      Text(
                        seeker.jobTitle
                            .trim()
                            .split(RegExp(r"\s+"))
                            .map((word) {
                              if (word.isEmpty) return '';
                              return "${word[0].toUpperCase()}${word.substring(1).toLowerCase()}";
                            })
                            .join(" "),
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.primaryColor,
                          fontWeight: .w500,
                        ),
                        maxLines: 1,
                        overflow: .ellipsis,
                      ),
                      //
                      verticalSpace(4.h),
                      //
                      Row(
                        children: [
                          // Location Icon
                          Icon(
                            Icons.location_on,
                            color: Colors.grey.shade500,
                            size: 14.sp,
                          ),
                          //
                          horizontalSpace(4.w),
                          //
                          Expanded(
                            child: Text(
                              seeker.locationName,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 1,
                              overflow: .ellipsis,
                            ),
                          ),
                          //
                        ],
                      ),
                      //
                    ],
                  ),
                ),
                //
                // Save Icon
                LikeButton(
                  size: 23.sp,
                  isLiked: isSaved,
                  onTap: (bool isCurrentlySaved) async {
                    if (onBookmarkTapOverride != null) {
                      return onBookmarkTapOverride(isCurrentlySaved);
                    }

                    if (!isCurrentlySaved) {
                      audioPlayer.play(AssetSource("sounds/save.mp3"));
                    }

                    context.read<CompanyHomeCubit>().toggleBookmark(
                      seeker.id.toString(),
                    );
                    return !isCurrentlySaved;
                  },
                  likeBuilder: (bool isLiked) {
                    return SvgPicture.asset(
                      isLiked
                          ? "assets/svgs/fill_saved.svg"
                          : "assets/svgs/saved.svg",
                      colorFilter: ColorFilter.mode(
                        isLiked ? AppColors.primaryColor : Colors.grey.shade400,
                        .srcIn,
                      ),
                      height: 23.sp,
                    );
                  },
                  circleColor: CircleColor(
                    start: AppColors.primaryColor.withValues(alpha: 0.5),
                    end: AppColors.primaryColor,
                  ),
                  bubblesColor: BubblesColor(
                    dotPrimaryColor: AppColors.primaryColor,
                    dotSecondaryColor: Colors.blueAccent,
                  ),
                  animationDuration: const Duration(milliseconds: 600),
                ),
                //
              ],
            ),
            //
            verticalSpace(16.h),
            // Chips
            Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              children: [
                _buildChip(
                  seeker.level,
                  Colors.blue.shade50,
                  AppColors.primaryColor.withValues(alpha: 0.7),
                ),
                _buildChip(
                  seeker.typeOfWork,
                  Colors.blue.shade50,
                  AppColors.primaryColor.withValues(alpha: 0.7),
                ),
                _buildChip(
                  seeker.jobCategory,
                  Colors.blue.shade50,
                  AppColors.primaryColor.withValues(alpha: 0.7),
                ),
              ],
            ),
            //
          ],
        ),
      ),
    );
  }

  ///
  Widget _buildChip(String label, Color bgColor, Color textColor) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: .symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(color: bgColor, borderRadius: .circular(8.r)),
      child: Text(
        label
            .trim()
            .split(RegExp(r"\s+"))
            .map((word) {
              if (word.isEmpty) return "";
              return "${word[0].toUpperCase()}${word.substring(1).toLowerCase()}";
            })
            .join(" "),
        style: TextStyle(color: textColor, fontSize: 12.sp, fontWeight: .w600),
      ),
    );
  }
}
