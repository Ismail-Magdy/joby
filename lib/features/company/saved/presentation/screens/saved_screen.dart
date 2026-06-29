import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joby/core/widgets/error_screen.dart';
import 'package:joby/features/company/saved/presentation/widgets/custom_saved_list.dart';
import 'package:joby/features/company/saved/presentation/widgets/empty_state_saved_widget.dart';
import 'package:joby/features/company/saved/presentation/widgets/saved_header_widget.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:joby/features/company/home/manager/company_home_cubit.dart';
import 'package:joby/features/company/home/manager/company_home_state.dart';
import 'package:joby/features/company/home/presentation/components/seeker_card.dart';
import 'package:joby/features/users/user_info/data/models/user_info_model.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // Header
          SavedHeaderWidget(),
          // Content
          Expanded(
            child: BlocBuilder<CompanyHomeCubit, CompanyHomeState>(
              builder: (context, state) {
                if (state is CompanyHomeLoading ||
                    state is CompanyHomeInitial) {
                  //
                  final dummySeeker = UserInfoModel(
                    name: "Skeleton Name Loading",
                    jobCategory: "Programming",
                    jobTitle: "Software Engineer",
                    level: "Senior",
                    typeOfWork: "Full-time",
                    whatsapp: "123456789",
                    locationName: "Cairo, Egypt",
                    latitude: 0,
                    longitude: 0,
                    totalPoints: 100,
                  );
                  //
                  return Skeletonizer(
                    enabled: true,
                    child: ListView.builder(
                      padding: .only(
                        top: 20.h,
                        left: 24.w,
                        right: 24.w,
                        bottom: 120.h,
                      ),
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        return SeekerCard(seeker: dummySeeker, isSaved: true);
                      },
                    ),
                  );
                  //
                } else if (state is CompanyHomeError) {
                  return ErrorScreen(errorText: state.message);
                } else if (state is CompanyHomeLoaded) {
                  final savedSeekers = state.seekers
                      .where(
                        (seeker) => state.savedSeekerIds.contains(seeker.id),
                      )
                      .toList();

                  if (savedSeekers.isEmpty) {
                    return EmptyStateSavedWidget();
                  }

                  return CustomSavedList(
                    savedSeekers: savedSeekers,
                    savedSeekerIds: state.savedSeekerIds,
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
// 290