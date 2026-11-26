import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ionicons/ionicons.dart';
import 'package:joby/core/themes/app_colors.dart';
import 'package:joby/core/helpers/spacing.dart';
import 'package:joby/core/widgets/app_skeletonizer.dart';
import 'package:joby/core/widgets/custom_app_bar_without_leading.dart';
import 'package:joby/core/widgets/error_screen.dart';
import 'package:joby/features/users/profile_views/manager/profile_views_cubit.dart';
import 'package:joby/features/users/profile_views/manager/profile_views_state.dart';
import 'package:joby/features/users/profile_views/presentation/widgets/profile_views_card_without_time.dart';
import 'package:lottie/lottie.dart';

class ProfileViewsScreen extends StatefulWidget {
  const ProfileViewsScreen({super.key});

  @override
  State<ProfileViewsScreen> createState() => _ProfileViewsScreenState();
}

class _ProfileViewsScreenState extends State<ProfileViewsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileViewsCubit>().fetchViews();
  }

  String _timeAgo(DateTime d) {
    Duration diff = DateTime.now().difference(d);
    if (diff.inDays > 365) return "${(diff.inDays / 365).floor()}y ago";
    if (diff.inDays > 30) return "${(diff.inDays / 30).floor()}mo ago";
    if (diff.inDays > 0) return "${diff.inDays}d ago";
    if (diff.inHours > 0) return "${diff.inHours}h ago";
    if (diff.inMinutes > 0) return "${diff.inMinutes}m ago";
    return "Just now";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      //
      appBar: CustomAppBarWithoutLeading(text: "Profile Views"),
      //
      body: SafeArea(
        child: BlocBuilder<ProfileViewsCubit, ProfileViewsState>(
          builder: (context, state) {
            //
            return Column(
              children: [
                // Loaded
                if (state is ProfileViewsLoaded)
                  //
                  //
                  Expanded(child: _buildBodyContent(state)),
              ],
            );
            //
          },
        ),
      ),
    );
  }

  ///
  Widget _buildBodyContent(ProfileViewsState state) {
    // Loading
    if (state is ProfileViewsLoading || state is ProfileViewsInitial) {
      return AppSkeletonizer(
        enabled: true,
        child: ListView.builder(
          padding: .symmetric(vertical: 10.h, horizontal: 20.w),
          itemCount: 5,
          itemBuilder: (context, index) {
            return Container(
              margin: .only(bottom: 12.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: .circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade100,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: .symmetric(horizontal: 16.w, vertical: 12.h),
                child: Row(
                  children: [
                    Container(
                      width: 55.w,
                      height: 55.w,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: .circle,
                      ),
                    ),
                    horizontalSpace(15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: .start,
                        children: [
                          Text(
                            "Company Name Placeholder",
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: .bold,
                            ),
                          ),
                          verticalSpace(6),
                          Text(
                            "2h ago",
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 44.w,
                      height: 24.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: .circular(12.r),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }
    //
    // Error
    else if (state is ProfileViewsError) {
      return ErrorScreen();
    }
    //
    // Empty
    else if (state is ProfileViewsEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            //
            Lottie.asset(
              "assets/lotties/no_views.json",
              width: 180.w,
              height: 180.h,
              fit: .contain,
            ),
            //
            verticalSpace(15),
            //
            Text(
              "No Profile Views Yet\nKeep Updating Your Profile",
              textAlign: .center,
              style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade700),
            ),
            //
          ],
        ),
      );
      //
      // Loaded
    } else if (state is ProfileViewsLoaded) {
      //
      return ListView.builder(
        padding: .symmetric(vertical: 10.h, horizontal: 20.w),
        itemCount: state.views.length,
        itemBuilder: (context, index) {
          final view = state.views[index];

          return Container(
            margin: .only(bottom: 12.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: .circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade100,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: Padding(
                padding: .symmetric(horizontal: 16.w, vertical: 12.h),
                child: Row(
                  children: [
                    // Company Avatar
                    Container(
                      width: 55.w,
                      height: 55.w,
                      decoration: BoxDecoration(
                        shape: .circle,
                        border: .all(color: Colors.grey.shade200, width: 1),
                        image: view.companyAvatar != null
                            ? DecorationImage(
                                image: CachedNetworkImageProvider(
                                  view.companyAvatar!,
                                ),
                                fit: .cover,
                              )
                            : null,
                      ),
                      child: view.companyAvatar == null
                          ? Icon(Ionicons.business, color: Colors.grey.shade400)
                          : null,
                    ),
                    //
                    horizontalSpace(15),
                    // Company Name, Badge & Time
                    Expanded(
                      child: Column(
                        crossAxisAlignment: .start,
                        children: [
                          // Fire Badge
                          ProfileViewsCardWithoutTime(
                            viewCompanyName: view.companyName,
                            viewViewCountInt: view.viewCount,
                            viewViewCountString: "x${view.viewCount}",
                          ),
                          //
                          verticalSpace(4),
                          //
                          Text(
                            _timeAgo(view.viewedAt),
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          //
                        ],
                      ),
                    ),

                    // New Badge OR Eye Icon
                    DateTime.now().difference(view.viewedAt).inHours < 24
                        //
                        ? Container(
                            padding: .symmetric(
                              horizontal: 10.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: .circular(12.r),
                            ),
                            child: Text(
                              "New",
                              style: TextStyle(
                                color: AppColors.primaryColor,
                                fontSize: 12.sp,
                                fontWeight: .bold,
                              ),
                            ),
                          )
                        //
                        : SvgPicture.asset(
                            "assets/svgs/eye.svg",
                            height: 22.h,
                            colorFilter: const .mode(
                              AppColors.primaryColor,
                              .srcIn,
                            ),
                          ),
                    //
                  ],
                ),
              ),
            ),
          );
        },
      );
      //
    }
    return const SizedBox.shrink();
  }
}
// 305
