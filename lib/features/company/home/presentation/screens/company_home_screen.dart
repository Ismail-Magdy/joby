import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:joby/core/helpers/spacing.dart';
import 'package:joby/core/widgets/error_screen.dart';
import 'package:joby/features/company/home/presentation/widgets/seeker_card.dart';
import 'package:lottie/lottie.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../users/user_info/data/models/user_info_model.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../manager/company_home_cubit.dart';
import '../../manager/company_home_state.dart';
import '../widgets/search_filter_bar.dart';

class CompanyHomeScreen extends StatefulWidget {
  const CompanyHomeScreen({super.key});

  @override
  State<CompanyHomeScreen> createState() => _CompanyHomeScreenState();
}

class _CompanyHomeScreenState extends State<CompanyHomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CompanyHomeCubit>().fetchSeekers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // Fixed Header
          SizedBox(
            height: 150.h,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // AppBar
                Container(
                  height: 125.h,
                  width: .infinity,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: .only(
                      bottomLeft: .circular(20.r),
                      bottomRight: .circular(20.r),
                    ),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      "assets/svgs/joby_logo.svg",
                      height: 60.h,
                      colorFilter: const .mode(Colors.white, .srcIn),
                    ),
                  ),
                ),
                // Search Filter Bar
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: const SearchFilterBar(),
                ),
                //
              ],
            ),
          ),

          Expanded(
            child: BlocBuilder<CompanyHomeCubit, CompanyHomeState>(
              builder: (context, state) {
                if (state is CompanyHomeLoading ||
                    state is CompanyHomeInitial) {
                  final dummySeeker = UserInfoModel(
                    id: '1',
                    name: "Skeleton Name Loading",
                    jobCategory: "Programming",
                    jobTitle: 'Software Engineer',
                    level: 'Senior',
                    typeOfWork: 'Full-time',
                    whatsapp: '123456789',
                    locationName: 'Cairo, Egypt',
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
                          ColorFiltered(
                            colorFilter: ColorFilter.mode(
                              AppColors.primaryColor,
                              .srcIn,
                            ),
                            child: Lottie.asset(
                              alignment: .center,
                              "assets/lotties/no_data.json",
                              width: 200.w,
                              height: 200.h,
                              fit: .cover,
                              repeat: true,
                            ),
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
                    padding: .only(
                      top: 24.h,
                      left: 24.w,
                      right: 24.w,
                      bottom: 24.h,
                    ),
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
          ),
        ],
      ),
    );
  }
}
