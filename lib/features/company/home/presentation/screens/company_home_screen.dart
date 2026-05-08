import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../manager/company_home_cubit.dart';
import '../../manager/company_home_state.dart';
import '../widgets/company_home_app_bar.dart';
import '../widgets/search_filter_bar.dart';
import '../widgets/seeker_card.dart';
import '../../../../../core/themes/app_colors.dart';

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
      appBar: const CompanyHomeAppBar(),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                const SearchFilterBar(),
                SizedBox(height: 24.h),
                _buildMockBanner(),
                SizedBox(height: 24.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Text(
                    "Top Talents",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
          BlocBuilder<CompanyHomeCubit, CompanyHomeState>(
            builder: (context, state) {
              if (state is CompanyHomeLoading) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (state is CompanyHomeError) {
                return SliverFillRemaining(
                  child: Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                );
              } else if (state is CompanyHomeLoaded) {
                if (state.seekers.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64.sp, color: Colors.grey.shade400),
                          SizedBox(height: 16.h),
                          Text(
                            "No talents found matching your criteria.",
                            style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final seeker = state.seekers[index];
                        final isSaved = state.savedSeekerIds.contains(seeker.name);
                        return SeekerCard(seeker: seeker, isSaved: isSaved);
                      },
                      childCount: state.seekers.length,
                    ),
                  ),
                );
              }

              return const SliverFillRemaining(child: SizedBox.shrink());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMockBanner() {
    return Container(
      height: 140.h,
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        gradient: LinearGradient(
          colors: [AppColors.primaryColor, AppColors.primaryColor.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(Icons.rocket_launch, size: 100.sp, color: Colors.white.withOpacity(0.1)),
          ),
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Hire Top Talent\nWith Joby",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    "Post a Job",
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
