import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joby/core/themes/app_colors.dart';
import 'package:joby/features/company/home/presentation/widgets/seeker_card.dart';
import 'package:joby/features/users/user_info/data/models/user_info_model.dart';
import 'package:joby/features/company/home/manager/company_home_cubit.dart';
import 'package:thanos_snap_effect/thanos_snap_effect.dart';

class CustomSavedList extends StatelessWidget {
  const CustomSavedList({
    super.key,
    required this.savedSeekers,
    required this.savedSeekerIds,
  });
  final List<UserInfoModel> savedSeekers;
  final Set<String> savedSeekerIds;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Padding(
          padding: .only(left: 24.w, right: 24.w, top: 20.h),
          child: Row(
            children: [
              //
              Container(
                padding: .symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: .circular(20.r),
                ),
                child: Text(
                  "${savedSeekers.length} Talent${savedSeekers.length != 1 ? 's' : ''} Saved",
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: .w600,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
              //
            ],
          ),
        ),
        //
        Expanded(
          child: ListView.builder(
            padding: .only(top: 16.h, left: 24.w, right: 24.w, bottom: 120.h),
            itemCount: savedSeekers.length,
            itemBuilder: (context, index) {
              final seeker = savedSeekers[index];
              return _AnimatableSavedCard(
                key: ValueKey(seeker.id),
                seeker: seeker,
              );
            },
          ),
        ),
        //
      ],
    );
  }
}

class _AnimatableSavedCard extends StatefulWidget {
  final UserInfoModel seeker;

  const _AnimatableSavedCard({super.key, required this.seeker});

  @override
  State<_AnimatableSavedCard> createState() => _AnimatableSavedCardState();
}

class _AnimatableSavedCardState extends State<_AnimatableSavedCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _snapController;
  bool _isSnapping = false;

  @override
  void initState() {
    super.initState();
    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _snapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Snappable(
      animation: _snapController,
      child: SeekerCard(
        seeker: widget.seeker,
        isSaved: true,
        onBookmarkTapOverride: (bool isCurrentlySaved) async {
          if (_isSnapping) return isCurrentlySaved;

          setState(() => _isSnapping = true);

          // Start the snap disintegration animation
          _snapController.forward();

          // Wait for the animation to complete
          await Future.delayed(const Duration(milliseconds: 800));

          // Actually remove from state & local storage
          if (mounted) {
            context.read<CompanyHomeCubit>().toggleBookmark(
              widget.seeker.id.toString(),
            );
          }

          // Return false so the LikeButton shows un-saved state
          return false;
        },
      ),
    );
  }
}
