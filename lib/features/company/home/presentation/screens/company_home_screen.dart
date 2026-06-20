import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../manager/company_home_cubit.dart';
import '../../manager/company_home_state.dart';
import '../widgets/search_filter_bar.dart';
import '../widgets/seeker_card.dart';

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
              clipBehavior: .none,
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
              ],
            ),
          ),
          //
          //
          Expanded(
            child: BlocBuilder<CompanyHomeCubit, CompanyHomeState>(
              builder: (context, state) {
                if (state is CompanyHomeLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is CompanyHomeError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                } else if (state is CompanyHomeLoaded) {
                  if (state.seekers.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64.sp,
                            color: Colors.grey.shade400,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            "No talents found matching your criteria.",
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // الـ ListView العادية عشان تسكرول لوحدها
                  return ListView.builder(
                    padding: EdgeInsets.only(
                      top: 24.h, // مسافة بين السيرش وأول كارت
                      left: 24.w,
                      right: 24.w,
                      bottom: 24.h,
                    ),
                    itemCount: state.seekers.length,
                    itemBuilder: (context, index) {
                      final seeker = state.seekers[index];
                      final isSaved = state.savedSeekerIds.contains(
                        seeker.name,
                      );
                      return SeekerCard(seeker: seeker, isSaved: isSaved);
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
