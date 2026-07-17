import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:joby/features/company/home/data/repos/company_home_repo.dart';
import 'package:joby/features/users/user_info/data/models/user_info_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
    List<UserInfoModel>? existingSavedProfiles;
    final bool alreadyHaveSaved = state is CompanyHomeLoaded;

    if (alreadyHaveSaved) {
      final loadedState = state as CompanyHomeLoaded;
      currentSaved = loadedState.savedSeekerIds;
      existingSavedProfiles = loadedState.savedSeekerProfiles;
    }

    emit(CompanyHomeLoading());

    // Start both futures simultaneously (parallel I/O)
    final seekersFuture = repo.getSeekers(
      searchQuery: currentSearchQuery,
      jobCategory: currentJobCategory,
      jobTitle: currentJobTitle,
      locationName: currentLocationName,
      level: currentLevel,
      page: _currentPage,
    );
    final savedFuture = alreadyHaveSaved ? null : repo.getSavedSeekerIds();

    // Await saved IDs if needed (runs in parallel with seekersFuture)
    if (savedFuture != null) {
      final savedResult = await savedFuture;
      savedResult.fold((error) => null, (saved) => currentSaved = saved);
    }

    // Await seekers
    final result = await seekersFuture;

    result.fold(
      (error) => emit(CompanyHomeError(error)),
      (seekers) => emit(
        CompanyHomeLoaded(
          seekers: seekers,
          savedSeekerIds: currentSaved,
          savedSeekerProfiles: existingSavedProfiles,
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

  /// Fetch full profiles for saved seeker IDs from Supabase
  Future<void> fetchSavedSeekers() async {
    if (state is! CompanyHomeLoaded) return;
    final currentState = state as CompanyHomeLoaded;

    if (currentState.savedSeekerIds.isEmpty) {
      emit(currentState.copyWith(savedSeekerProfiles: []));
      return;
    }

    final result = await repo.getSeekersByIds(currentState.savedSeekerIds);
    // Only emit if state hasn't changed underneath us
    if (state is! CompanyHomeLoaded) return;
    result.fold(
      (error) => null, // Keep current profiles on error
      (profiles) => emit(
        (state as CompanyHomeLoaded).copyWith(savedSeekerProfiles: profiles),
      ),
    );
  }

  /// Record a profile view in the Supabase database
  Future<void> recordProfileView(String seekerId) async {
    try {
      final companyId = Supabase.instance.client.auth.currentUser?.id;
      if (companyId == null) return;

      await Supabase.instance.client.from('profile_views').insert({
        'company_id': companyId,
        'seeker_id': seekerId,
      });

      debugPrint('✅ Profile view recorded successfully!');
    } catch (e) {
      debugPrint('🚨 Error recording profile view: $e');
    }
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
      List<UserInfoModel>? updatedProfiles =
          currentState.savedSeekerProfiles != null
          ? List<UserInfoModel>.from(currentState.savedSeekerProfiles!)
          : null;

      if (newSaved.contains(uniqueId)) {
        newSaved.remove(uniqueId);
        updatedProfiles?.removeWhere((s) => s.id == uniqueId);
      } else {
        newSaved.add(uniqueId);
        // Add to saved profiles if we have the full profile loaded
        if (updatedProfiles != null) {
          final matches = currentState.seekers.where((s) => s.id == uniqueId);
          if (matches.isNotEmpty) {
            updatedProfiles.add(matches.first);
          }
        }
      }

      emit(
        currentState.copyWith(
          savedSeekerIds: newSaved,
          savedSeekerProfiles: updatedProfiles,
        ),
      );
      repo.saveSeekerIds(newSaved);
    }
  }
}
