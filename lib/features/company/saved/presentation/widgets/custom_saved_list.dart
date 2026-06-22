import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joby/core/themes/app_colors.dart';
import 'package:joby/features/company/home/presentation/widgets/seeker_card.dart';
import 'package:joby/features/users/user_info/data/models/user_info_model.dart';

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
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: .only(top: 16.h, left: 24.w, right: 24.w, bottom: 120.h),
            itemCount: savedSeekers.length,
            itemBuilder: (context, index) {
              final seeker = savedSeekers[index];
              return AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: SeekerCard(
                  key: ValueKey(seeker.id),
                  seeker: seeker,
                  isSaved: true,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
