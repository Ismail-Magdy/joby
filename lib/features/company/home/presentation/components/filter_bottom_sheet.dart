import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:joby/core/helpers/extensions.dart';
import 'package:joby/core/helpers/spacing.dart';
import 'package:joby/features/company/home/presentation/widgets/action_filtter_buttons.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../manager/company_home_cubit.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String? selectedTitle;
  String? selectedCountry;
  String? selectedCity;
  String? selectedLevel;

  //
  final List<String> titles = [
    'All',
    'Flutter Developer',
    'Android Developer',
    'iOS Developer',
    'Backend Developer',
    'Frontend Developer',
    'Full Stack Developer',
    'UI/UX Designer',
    'Graphic Designer',
    'Mechatronics Engineer',
    'Mechanical Engineer',
    'Data Scientist',
    'Data Analyst',
    'Project Manager',
    'DevOps Engineer',
  ];

  //
  final Map<String, List<String>> locationsMap = {
    'All': ['All'],
    'Egypt': ['All', 'Cairo', 'Giza', 'Alexandria', 'Mansoura', 'Assiut'],
    'Saudi Arabia': ['All', 'Riyadh', 'Jeddah', 'Dammam', 'Mecca'],
    'UAE': ['All', 'Dubai', 'Abu Dhabi', 'Sharjah'],
    'Remote': ['All', 'Worldwide'],
  };

  //
  final List<String> levels = [
    'All',
    'Junior',
    'Mid-level',
    'Senior',
    'Team Lead',
    'Manager',
  ];

  @override
  void initState() {
    super.initState();
    final cubit = context.read<CompanyHomeCubit>();
    selectedTitle = titles.contains(cubit.currentJobTitle)
        ? cubit.currentJobTitle
        : 'All';
    selectedLevel = levels.contains(cubit.currentLevel)
        ? cubit.currentLevel
        : 'All';
    selectedCountry = 'All';
    selectedCity = 'All';

    if (cubit.currentLocationName != null) {
      String loc = cubit.currentLocationName!;
      locationsMap.forEach((country, cities) {
        if (country == loc) {
          selectedCountry = country;
          selectedCity = 'All';
        } else if (cities.contains(loc)) {
          selectedCountry = country;
          selectedCity = loc;
        }
      });
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
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Job Title Dropdown
                  _buildDropdown("Job Title", titles, selectedTitle, (val) {
                    setState(() => selectedTitle = val);
                  }),
                  //
                  verticalSpace(16),
                  //
                  // Country Dropdown
                  _buildDropdown(
                    "Country",
                    locationsMap.keys.toList(),
                    selectedCountry,
                    (val) {
                      setState(() {
                        selectedCountry = val;
                        selectedCity = 'All';
                      });
                    },
                  ),
                  //
                  verticalSpace(16),
                  //
                  // City Dropdown
                  if (selectedCountry != null && selectedCountry != 'All') ...[
                    //
                    _buildDropdown(
                      "City",
                      locationsMap[selectedCountry] ?? ['All'],
                      selectedCity,
                      (val) {
                        setState(() => selectedCity = val);
                      },
                    ),
                    //
                    verticalSpace(16),
                    //
                  ],
                  //
                  // Experience Level Dropdown
                  _buildDropdown("Experience Level", levels, selectedLevel, (
                    val,
                  ) {
                    setState(() => selectedLevel = val);
                  }),
                  //
                  verticalSpace(32),
                  //
                ],
              ),
            ),
          ),
          //
          // Action Buttons
          ActionFiltterButtons(
            onPressedClearFilters: () {
              context.read<CompanyHomeCubit>().clearFilters();
              context.pop();
            },
            onPressed: () {
              String? finalLocation;
              if (selectedCity != 'All') {
                finalLocation = selectedCity;
              } else if (selectedCountry != 'All') {
                finalLocation = selectedCountry;
              }

              context.read<CompanyHomeCubit>().applyFilters(
                jobCategory: null,
                jobTitle: selectedTitle == 'All' ? null : selectedTitle,
                locationName: finalLocation,
                level: selectedLevel == 'All' ? null : selectedLevel,
              );
              context.pop();
            },
          ),
          //
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        verticalSpace(8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey.shade200),
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
              borderRadius: BorderRadius.circular(12.r),
              elevation: 3,
              items: items.asMap().entries.map((entry) {
                int index = entry.key;
                String item = entry.value;
                bool isLastItem = index == items.length - 1;

                return DropdownMenuItem<String>(
                  value: item,
                  child: Container(
                    width: double.infinity,
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
                    alignment: Alignment.centerLeft,
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
