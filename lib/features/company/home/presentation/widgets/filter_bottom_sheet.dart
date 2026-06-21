import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:joby/core/helpers/spacing.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../manager/company_home_cubit.dart';
import '../../manager/company_home_state.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String? selectedTitle;
  String? selectedLocation;
  String? selectedLevel;

  List<String> titles = ['All'];
  List<String> locations = ['All'];
  List<String> levels = ['All'];

  static String _formatAndTranslate(String text) {
    if (text.isEmpty) return "";

    String cleanText = text.trim();

    final Map<String, String> arabicToEnglishDictionary = {
      'القاهرة': 'Cairo',
      'الجيزة': 'Giza',
      'الاسكندرية': 'Alexandria',
      'الإسكندرية': 'Alexandria',
      'عن بعد': 'Remote',
      'مطور فلاتر': 'Flutter Developer',
      'مهندس ميكاترونكس': 'Mechatronics Engineer',
      'ميكاترونكس': 'Mechatronics Engineer',
      'مبرمج': 'Programmer',
      'مصمم': 'Designer',
      'جونيور': 'Junior',
      'سينير': 'Senior',
      'مبتدئ': 'Junior',
      'خبير': 'Senior',
    };

    if (arabicToEnglishDictionary.containsKey(cleanText)) {
      cleanText = arabicToEnglishDictionary[cleanText]!;
    }

    return cleanText
        .split(RegExp(r"\s+"))
        .map((word) {
          if (word.isEmpty) return "";
          return "${word[0].toUpperCase()}${word.substring(1).toLowerCase()}";
        })
        .join(" ");
  }

  @override
  void initState() {
    super.initState();
    final cubit = context.read<CompanyHomeCubit>();

    selectedTitle = cubit.currentJobTitle != null
        ? _formatAndTranslate(cubit.currentJobTitle!)
        : 'All';
    selectedLocation = cubit.currentLocationName != null
        ? _formatAndTranslate(cubit.currentLocationName!)
        : 'All';
    selectedLevel = cubit.currentLevel != null
        ? _formatAndTranslate(cubit.currentLevel!)
        : 'All';

    if (cubit.state is CompanyHomeLoaded) {
      final seekers = (cubit.state as CompanyHomeLoaded).seekers;

      Set<String> titleSet = {};
      Set<String> locationSet = {};
      Set<String> levelSet = {};

      for (var seeker in seekers) {
        if (seeker.jobTitle.isNotEmpty) {
          titleSet.add(_formatAndTranslate(seeker.jobTitle));
        }
        if (seeker.locationName.isNotEmpty) {
          locationSet.add(_formatAndTranslate(seeker.locationName));
        }
        if (seeker.level.isNotEmpty) {
          levelSet.add(_formatAndTranslate(seeker.level));
        }
      }

      titles = ['All', ...titleSet.toList()..sort()];
      locations = ['All', ...locationSet.toList()..sort()];
      levels = ['All', ...levelSet.toList()..sort()];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: .symmetric(horizontal: 24.w, vertical: 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: .only(
          topLeft: .circular(24.r),
          topRight: .circular(24.r),
        ),
      ),
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: .circular(2.r),
              ),
            ),
          ),
          //
          verticalSpace(24),
          //
          Text(
            "Filter Talents",
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: .bold,
              color: AppColors.primaryColor,
            ),
          ),
          //
          verticalSpace(24),
          //
          if (titles.length > 1) ...[
            _buildDropdown("Job Title", titles, selectedTitle, (val) {
              setState(() => selectedTitle = val);
            }),
            SizedBox(height: 16.h),
          ],

          if (locations.length > 1) ...[
            _buildDropdown("Location", locations, selectedLocation, (val) {
              setState(() => selectedLocation = val);
            }),
            SizedBox(height: 16.h),
          ],

          if (levels.length > 1) ...[
            _buildDropdown("Experience Level", levels, selectedLevel, (val) {
              setState(() => selectedLevel = val);
            }),
            SizedBox(height: 32.h),
          ],
          //
          Row(
            children: [
              //
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    context.read<CompanyHomeCubit>().clearFilters();
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: .symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: .circular(12.r),
                    ),
                    side: BorderSide(color: AppColors.primaryColor),
                  ),
                  child: Text(
                    "Reset",
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
              ),
              //
              horizontalSpace(16),
              //
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    context.read<CompanyHomeCubit>().applyFilters(
                      jobCategory: null,
                      jobTitle: selectedTitle == 'All' ? null : selectedTitle,
                      locationName: selectedLocation == 'All'
                          ? null
                          : selectedLocation,
                      level: selectedLevel == 'All' ? null : selectedLevel,
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: .symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: .circular(12.r),
                    ),
                  ),
                  child: Text(
                    "Apply Filters",
                    style: TextStyle(color: Colors.white, fontSize: 16.sp),
                  ),
                ),
              ),
              //
            ],
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    String? value,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: .w600,
            color: Colors.grey.shade700,
          ),
        ),
        verticalSpace(8),
        Container(
          padding: .symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: .circular(12.r),
            border: .all(color: Colors.grey.shade200),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.grey.shade600,
              ),
              dropdownColor: Colors.white,
              borderRadius: .circular(12.r),
              elevation: 3,
              items: items.asMap().entries.map((entry) {
                int index = entry.key;
                String item = entry.value;
                bool isLastItem = index == items.length - 1;

                return DropdownMenuItem<String>(
                  value: item,
                  child: Container(
                    width: .infinity,
                    decoration: BoxDecoration(
                      border: isLastItem
                          ? null
                          : Border(
                              bottom: BorderSide(
                                color: Colors.grey.shade100,
                                width: 1,
                              ),
                            ),
                    ),
                    alignment: .centerLeft,
                    child: Text(
                      item,
                      style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                    ),
                  ),
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
