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

  // Pagination tracking
  static const int _pageSize = 10;
  int _currentPage = 0;
  bool _isFetchingMore = false;

  CompanyHomeCubit({required this.repo}) : super(CompanyHomeInitial());

  ///
  Future<void> fetchSeekers() async {
    _currentPage = 0;
    _isFetchingMore = false;

    Set<String> currentSaved = {};
    if (state is CompanyHomeLoaded) {
      currentSaved = (state as CompanyHomeLoaded).savedSeekerIds;
    } else {
      final savedResult = await repo.getSavedSeekerIds();
      savedResult.fold((error) => null, (saved) => currentSaved = saved);
    }

    emit(CompanyHomeLoading());

    final result = await repo.getSeekers(
      searchQuery: currentSearchQuery,
      jobCategory: currentJobCategory,
      jobTitle: currentJobTitle,
      locationName: currentLocationName,
      level: currentLevel,
      page: _currentPage,
    );

    result.fold(
      (error) => emit(CompanyHomeError(error)),
      (seekers) => emit(
        CompanyHomeLoaded(
          seekers: seekers,
          savedSeekerIds: currentSaved,
          hasReachedMax: seekers.length < _pageSize,
        ),
      ),
    );
  }

  ///
  Future<void> fetchNextPage() async {
    if (state is! CompanyHomeLoaded) return;
    final currentState = state as CompanyHomeLoaded;
    if (currentState.hasReachedMax || _isFetchingMore) return;

    _isFetchingMore = true;
    emit(currentState.copyWith(isLoadingMore: true));

    final nextPage = _currentPage + 1;

    final result = await repo.getSeekers(
      searchQuery: currentSearchQuery,
      jobCategory: currentJobCategory,
      jobTitle: currentJobTitle,
      locationName: currentLocationName,
      level: currentLevel,
      page: nextPage,
    );

    result.fold(
      (error) {
        emit(currentState.copyWith(isLoadingMore: false));
      },
      (newSeekers) {
        _currentPage = nextPage;
        final updatedList = List.of(currentState.seekers)..addAll(newSeekers);
        emit(
          currentState.copyWith(
            seekers: updatedList,
            isLoadingMore: false,
            hasReachedMax: newSeekers.length < _pageSize,
          ),
        );
      },
    );

    _isFetchingMore = false;
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
      repo.saveSeekerIds(newSaved);
    }
  }
}
