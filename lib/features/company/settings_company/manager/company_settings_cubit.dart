import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:joby/features/users/settings_users/data/models/app_rating_model.dart';
import '../data/repos/company_settings_repo.dart';
import 'company_settings_state.dart';

class CompanySettingsCubit extends Cubit<CompanySettingsState> {
  final CompanySettingsRepo companySettingsRepo;

  CompanySettingsCubit({required this.companySettingsRepo})
    : super(const CompanySettingsState());

  Future<void> loadSettings() async {
    final cached = companySettingsRepo.getCachedCompanyProfile();
    if (cached != null) {
      emit(
        state.copyWith(
          companyName: cached.name,
          avatarUrl: cached.avatarUrl,
        ),
      );
    } else {
      emit(state.copyWith(isLoadingProfile: true));
    }

    final profileResult = await companySettingsRepo.fetchCompanyProfile();
    if (isClosed) return;
    profileResult.fold(
      (_) => emit(state.copyWith(isLoadingProfile: false)),
      (profile) => emit(
        state.copyWith(
          companyName: profile.name,
          avatarUrl: profile.avatarUrl,
          clearAvatar: profile.avatarUrl == null,
          isLoadingProfile: false,
        ),
      ),
    );

    final ratingResult = await companySettingsRepo.getUserRating();
    if (isClosed) return;
    ratingResult.fold(
      (_) {},
      (rating) {
        if (rating != null) {
          emit(state.copyWith(savedRating: rating));
        }
      },
    );
  }

  Future<void> updateCompanyProfile({
    required String name,
    File? newAvatarFile,
  }) async {
    emit(state.copyWith(isSavingProfile: true, profileError: null));

    final result = await companySettingsRepo.updateCompanyProfile(
      name: name,
      newAvatarFile: newAvatarFile,
      existingAvatarUrl: state.avatarUrl,
    );
    if (isClosed) return;

    result.fold(
      (error) => emit(
        state.copyWith(
          isSavingProfile: false,
          profileError: error,
        ),
      ),
      (updated) => emit(
        state.copyWith(
          companyName: updated.name,
          avatarUrl: updated.avatarUrl,
          clearAvatar: updated.avatarUrl == null,
          isSavingProfile: false,
          profileSaveSuccess: true,
        ),
      ),
    );
  }

  Future<void> submitRating({
    required int rating,
    String? comment,
  }) async {
    emit(state.copyWith(isSubmittingRating: true, ratingError: null));

    final result = await companySettingsRepo.submitAppRating(
      rating: rating,
      comment: comment,
    );
    if (isClosed) return;

    result.fold(
      (error) => emit(
        state.copyWith(
          isSubmittingRating: false,
          ratingError: error,
        ),
      ),
      (_) {
        final trimmed = comment?.trim();
        emit(
          state.copyWith(
            isSubmittingRating: false,
            savedRating: AppRatingModel(
              rating: rating,
              comment: (trimmed == null || trimmed.isEmpty) ? null : trimmed,
            ),
            ratingSubmitSuccess: true,
          ),
        );
      },
    );
  }
}
