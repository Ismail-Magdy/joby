import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../manager/company_home_cubit.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String? selectedCategory;
  String? selectedTitle;
  String? selectedLocation;
  String? selectedLevel;

  // Mock Data for filters
  final List<String> categories = ['All', 'Programming', 'Design', 'Marketing', 'Engineering'];
  final List<String> titles = ['All', 'Flutter Developer', 'UI/UX Designer', 'Backend Engineer'];
  final List<String> locations = ['All', 'Cairo', 'Alexandria', 'Giza', 'Remote'];
  final List<String> levels = ['All', 'Junior', 'Mid-Level', 'Senior'];

  @override
  void initState() {
    super.initState();
    final cubit = context.read<CompanyHomeCubit>();
    selectedCategory = cubit.currentJobCategory ?? 'All';
    selectedTitle = cubit.currentJobTitle ?? 'All';
    selectedLocation = cubit.currentLocationName ?? 'All';
    selectedLevel = cubit.currentLevel ?? 'All';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            "Filter Talents",
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
          SizedBox(height: 24.h),
          _buildDropdown("Job Category", categories, selectedCategory, (val) {
            setState(() => selectedCategory = val);
          }),
          SizedBox(height: 16.h),
          _buildDropdown("Job Title", titles, selectedTitle, (val) {
            setState(() => selectedTitle = val);
          }),
          SizedBox(height: 16.h),
          _buildDropdown("Location", locations, selectedLocation, (val) {
            setState(() => selectedLocation = val);
          }),
          SizedBox(height: 16.h),
          _buildDropdown("Experience Level", levels, selectedLevel, (val) {
            setState(() => selectedLevel = val);
          }),
          SizedBox(height: 32.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    context.read<CompanyHomeCubit>().clearFilters();
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    side: BorderSide(color: AppColors.primaryColor),
                  ),
                  child: Text(
                    "Reset",
                    style: TextStyle(color: AppColors.primaryColor, fontSize: 16.sp),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    context.read<CompanyHomeCubit>().applyFilters(
                      jobCategory: selectedCategory == 'All' ? null : selectedCategory,
                      jobTitle: selectedTitle == 'All' ? null : selectedTitle,
                      locationName: selectedLocation == 'All' ? null : selectedLocation,
                      level: selectedLevel == 'All' ? null : selectedLevel,
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    "Apply Filters",
                    style: TextStyle(color: Colors.white, fontSize: 16.sp),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom), // Adjust for keyboard
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? value, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item, style: TextStyle(fontSize: 14.sp)),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
