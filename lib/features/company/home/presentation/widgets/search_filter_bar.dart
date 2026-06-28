import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../manager/company_home_cubit.dart';
import '../components/filter_bottom_sheet.dart';

class SearchFilterBar extends StatefulWidget {
  const SearchFilterBar({super.key});

  @override
  State<SearchFilterBar> createState() => _SearchFilterBarState();
}

class _SearchFilterBarState extends State<SearchFilterBar> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<CompanyHomeCubit>().applyFilters(searchQuery: value);
    });
  }

  void _openFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<CompanyHomeCubit>(),
        child: const FilterBottomSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: .symmetric(horizontal: 24.w),
      child: Container(
        height: 50.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: .circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          textAlignVertical: .center,
          decoration: InputDecoration(
            hintText: "Search",
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
            prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
            suffixIcon: GestureDetector(
              onTap: _openFilterBottomSheet,
              child: Container(
                margin: .only(right: 6.w, top: 5.h, bottom: 5.h),
                width: 40.w,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: .circular(12.r),
                ),
                child: const Icon(Icons.tune, color: Colors.white, size: 20),
              ),
            ),
            border: .none,
            contentPadding: .symmetric(horizontal: 16.w),
          ),
        ),
      ),
    );
  }
}
