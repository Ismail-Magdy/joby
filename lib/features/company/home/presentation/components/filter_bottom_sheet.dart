import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:joby/core/helpers/extensions.dart';
import 'package:joby/core/helpers/spacing.dart';
import 'package:joby/core/helpers/job_suggestions.dart'; // 🔥 ضفنا دي عشان نوحد البيانات
import 'package:joby/features/company/home/presentation/widgets/action_filtter_buttons.dart';
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
  String? selectedCountry;
  String? selectedCity;
  String? selectedLevel;

  //
  late List<String> categories;
  late List<String> titles;

  //
  final Map<String, List<String>> locationsMap = {
    'All': ['All'],
    'Egypt': [
      'All',
      'Cairo',
      'Giza',
      'Alexandria',
      'Mansoura',
      'Assiut',
      'Qalyubia',
      "Al Minya",
      "Aswan",
      "Luxor",
      "Suez",
      "Port Said",
      "Ismailia",
      "Fayoum",
      "Beni Suef",
      "Daqahliya",
      "Sharqia",
      "Kafr El Sheikh",
      "Beheira",
      "Sohag",
      "Qena",
      "Red Sea",
      "New Valley",
      "North Sinai",
      "South Sinai",
      "Damietta",
      "Menoufia",
      "Gharbia",
    ],
    'Saudi Arabia': [
      'All',
      'Riyadh',
      'Jeddah',
      'Dammam',
      'Mecca',
      'Al Madinah',
      'Al Khobar',
      'Tabuk',
      'Buraidah',
      'Khamis Mushait',
      'Hail',
      'Najran',
      'Al Ahsa',
      'Jazan',
      'Yanbu',
      'Al Jubail',
      'Abha',
      'Taif',
      'Al Qassim',
      'Al Baha',
      'Arar',
      'Sakaka',
      'Al Kharj',
      'Al Qunfudhah',
      'Al Wajh',
      'Al Ula',
      'Dahna',
      'Rafha',
      'Turaif',
    ],
    'Qatar': [
      'All',
      'Doha',
      'Al Rayyan',
      'Al Wakrah',
      'Al Khor',
      'Al Shamal',
      'Al Daayen',
      'Umm Salal',
      'Al Shahaniya',
      'Al Jumail',
      'Al Ghuwariyah',
      'Mesaieed',
      "Dukhan",
    ],
    'UAE': [
      'All',
      'Dubai',
      'Abu Dhabi',
      'Sharjah',
      'Ajman',
      'Fujairah',
      'Ras Al Khaimah',
      'Umm Al Quwain',
      'Al Ain',
      'Khor Fakkan',
      'Dibba Al-Fujairah',
      'Kalba',
      'Masafi',
      'Hatta',
      'Jebel Ali',
      'Mussafah',
      'Al Hamriyah',
      'Al Dhaid',
      'Al Madam',
      'Al Liwa',
      'Al Jazirah Al Hamra',
      'Al Faqa',
      'Al Qusais',
      'Al Safa',
      'Al Satwa',
      'Al Warqa',
      'Jumeirah',
      'Jumeirah Beach Residence (JBR)',
      'Palm Jumeirah',
      'The World Islands',
      'Bluewaters Island',
      'Dubai Marina',
      'Business Bay',
      'Downtown Dubai',
      'Al Barsha',
      'Al Quoz',
      'Al Wasl',
      'Al Mankhool',
      'Al Karama',
      'Al Jaddaf',
      'Al Sufouh',
      'Al Warqa 1-4',
      'Al Mizhar',
      'Al Twar 1-3',
      'Al Rashidiya',
      'Al Khawaneej',
      'Al Awir',
      'Al Qusais Industrial Area 1-3',
      'Al Quoz Industrial Area 1-4',
      'Al Jafiliya',
      'Al Mamzar',
      'Al Nahda 1-2',
      'Al Barsha South',
      'Al Barsha Heights (Tecom)',
      'Al Barsha 1-3',
      'Al Barsha South 1-2',
      'Al Barsha South 3-4',
      'Al Barsha South 5-6',
      'Al Barsha South 7-8',
      'Al Barsha South 9-10',
      'Al Barsha South 11-12',
      'Al Barsha South 13-14',
      'Al Barsha South 15-16',
      'Al Barsha South 17-18',
      'Al Barsha South 19-20',
      'Al Barsha South 21-22',
      'Al Barsha South 23-24',
    ],
    'Remote': ['All', 'Worldwide'],
  };
  //
  //
  final List<String> levels = ['All', 'Junior', 'Mid-Level', 'Senior', 'Lead'];

  @override
  void initState() {
    super.initState();
    final cubit = context.read<CompanyHomeCubit>();

    categories = ['All', ...JobSuggestions.categories];
    titles = ['All', ...JobSuggestions.titles];

    selectedCategory = categories.contains(cubit.currentJobCategory)
        ? cubit.currentJobCategory
        : 'All';

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
                  //  Job Category Dropdown
                  _buildDropdown("Job Category", categories, selectedCategory, (
                    val,
                  ) {
                    setState(() {
                      selectedCategory = val;
                      selectedTitle = 'All';
                    });
                  }),
                  //
                  verticalSpace(16),
                  //
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
                jobCategory: selectedCategory == 'All'
                    ? null
                    : selectedCategory,
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
      crossAxisAlignment: .start,
      children: [
        //
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: .w600,
            color: Colors.grey.shade700,
          ),
        ),
        //
        verticalSpace(8),
        //
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
