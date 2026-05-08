import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:joby/features/company/home/data/repos/company_home_repo.dart';
import 'company_home_state.dart';

class CompanyHomeCubit extends Cubit<CompanyHomeState> {
  final CompanyHomeRepo repo;

  // Track current filters
  String? currentSearchQuery;
  String? currentJobCategory;
  String? currentJobTitle;
  String? currentLocationName;
  String? currentLevel;

  CompanyHomeCubit({required this.repo}) : super(CompanyHomeInitial());

  Future<void> fetchSeekers() async {
    // Retain saved seekers if we are already in Loaded state
    Set<String> currentSaved = {};
    if (state is CompanyHomeLoaded) {
      currentSaved = (state as CompanyHomeLoaded).savedSeekerIds;
    }

    emit(CompanyHomeLoading());

    final result = await repo.getSeekers(
      searchQuery: currentSearchQuery,
      jobCategory: currentJobCategory,
      jobTitle: currentJobTitle,
      locationName: currentLocationName,
      level: currentLevel,
    );

    result.fold(
      (error) => emit(CompanyHomeError(error)),
      (seekers) => emit(
        CompanyHomeLoaded(seekers: seekers, savedSeekerIds: currentSaved),
      ),
    );
  }

  void applyFilters({
    String? searchQuery,
    String? jobCategory,
    String? jobTitle,
    String? locationName,
    String? level,
  }) {
    currentSearchQuery = searchQuery ?? currentSearchQuery;
    currentJobCategory = jobCategory;
    currentJobTitle = jobTitle;
    currentLocationName = locationName;
    currentLevel = level;

    fetchSeekers();
  }

  void clearFilters() {
    currentSearchQuery = null;
    currentJobCategory = null;
    currentJobTitle = null;
    currentLocationName = null;
    currentLevel = null;

    fetchSeekers();
  }

  void toggleBookmark(String uniqueId) {
    if (state is CompanyHomeLoaded) {
      final currentState = state as CompanyHomeLoaded;
      final newSaved = Set<String>.from(currentState.savedSeekerIds);

      if (newSaved.contains(uniqueId)) {
        newSaved.remove(uniqueId);
      } else {
        newSaved.add(uniqueId);
      }

      emit(currentState.copyWith(savedSeekerIds: newSaved));
    }
  }
}
