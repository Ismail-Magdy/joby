import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ionicons/ionicons.dart';
import 'package:joby/core/helpers/spacing.dart';
import 'package:joby/core/themes/app_colors.dart';
import 'package:joby/core/widgets/custom_app_bar_with_no_leading.dart';
import 'package:joby/core/widgets/error_screen.dart';
import 'package:joby/features/users/profile_views/manager/profile_views_cubit.dart';
import 'package:joby/features/users/profile_views/manager/profile_views_state.dart';

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
      appBar: CustomAppBarWithNoLeading(text: "Profile Views"),
      //
      body: BlocBuilder<ProfileViewsCubit, ProfileViewsState>(
        builder: (context, state) {
          // Loading
          if (state is ProfileViewsLoading) {
            return const Center(
              child: CupertinoActivityIndicator(color: AppColors.primaryColor),
            );
          }
          //
          // Error
          else if (state is ProfileViewsError) {
            return ErrorScreen(errorText: state.message);
          }
          //
          // Empty State
          else if (state is ProfileViewsEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: .center,
                children: [
                  //
                  Icon(
                    Ionicons.eye_off_outline,
                    size: 80.sp,
                    color: Colors.grey.shade300,
                  ),
                  //
                  verticalSpace(15),
                  //
                  Text(
                    "No views yet!\nKeep updating your profile",
                    textAlign: .center,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  //
                ],
              ),
            );
          }
          //
          // Loaded
          else if (state is ProfileViewsLoaded) {
            return ListView.builder(
              padding: .symmetric(vertical: 10.h, horizontal: 16.w),
              itemCount: state.views.length,
              itemBuilder: (context, index) {
                final view = state.views[index];

                // أنيميشن لذيذ للستة (بيظهر العناصر ورا بعض بـ Delay بسيط)
                return TweenAnimationBuilder<double>(
                  duration: Duration(
                    milliseconds: 400 + (index * 100).clamp(0, 500),
                  ),
                  tween: Tween(begin: 0.0, end: 1.0),
                  curve: Curves.easeOutQuart,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 50 * (1 - value)),
                      child: Opacity(opacity: value, child: child),
                    );
                  },
                  child: Container(
                    margin: .only(bottom: 16.h),
                    child: Row(
                      children: [
                        // Company Image
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
                              ? Icon(
                                  Ionicons.business,
                                  color: Colors.grey.shade400,
                                )
                              : null,
                        ),
                        //
                        horizontalSpace(15),
                        //
                        // Company Name & Time
                        Expanded(
                          child: Column(
                            crossAxisAlignment: .start,
                            children: [
                              //
                              Text(
                                view.companyName,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: .bold,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: .ellipsis,
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
                        //
                        // زرار View Company (مكان زرار الفولو في تيك توك)
                        ElevatedButton(
                          onPressed: () {
                            // TODO: انتقل لصفحة تفاصيل الشركة باستخدام view.companyId
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xffF0F0F0),
                            elevation: 0,
                            padding: .symmetric(
                              horizontal: 16.w,
                              vertical: 8.h,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: .circular(8.r),
                            ),
                          ),
                          child: Text(
                            "View",
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: .bold,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                        //
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
