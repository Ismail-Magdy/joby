import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joby/core/helpers/spacing.dart';
import 'package:joby/core/widgets/error_screen.dart';
import 'package:joby/features/company/home/manager/company_home_cubit.dart';
import 'package:joby/features/company/home/manager/company_home_state.dart';
import 'package:joby/features/company/home/presentation/components/seeker_card.dart';
import 'package:joby/features/users/user_info/data/models/user_info_model.dart';
import 'package:lottie/lottie.dart';
import 'package:skeletonizer/skeletonizer.dart';

class BottomSectionCompanyHome extends StatelessWidget {
  const BottomSectionCompanyHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BlocBuilder<CompanyHomeCubit, CompanyHomeState>(
        builder: (context, state) {
          if (state is CompanyHomeLoading || state is CompanyHomeInitial) {
            final dummySeeker = UserInfoModel(
              id: "1",
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
                  top: 24.h,
                  left: 24.w,
                  right: 24.w,
                  bottom: 24.h,
                ),
                itemCount: 4,
                itemBuilder: (context, index) {
                  return SeekerCard(seeker: dummySeeker, isSaved: false);
                },
              ),
            );
            // Error State
          } else if (state is CompanyHomeError) {
            return ErrorScreen(errorText: state.message);
            // Succsess State
          } else if (state is CompanyHomeLoaded) {
            if (state.seekers.isEmpty) {
              return Center(
                //
                child: Column(
                  mainAxisAlignment: .center,
                  children: [
                    //
                    Lottie.asset(
                      alignment: .center,
                      "assets/lotties/no_data.json",
                      width: 200.w,
                      height: 200.h,
                      fit: .cover,
                      repeat: true,
                    ),
                    //
                    verticalSpace(5),
                    //
                    Text(
                      "No Talents Found Matching Your Criteria",
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    //
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: .only(top: 24.h, left: 24.w, right: 24.w, bottom: 24.h),
              itemCount: state.seekers.length,
              itemBuilder: (context, index) {
                final seeker = state.seekers[index];
                final isSaved = state.savedSeekerIds.contains(seeker.id);
                return SeekerCard(
                  key: ValueKey(seeker.id),
                  seeker: seeker,
                  isSaved: isSaved,
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
    //
  }
}
