import 'package:joby/features/users/settings_users/data/models/app_rating_model.dart';

class CompanySettingsState {
  final String companyName;
  final String? avatarUrl;
  final bool isLoadingProfile;
  final bool isSavingProfile;
  final String? profileError;
  final bool profileSaveSuccess;
  final AppRatingModel? savedRating;
  final bool isSubmittingRating;
  final String? ratingError;
  final bool ratingSubmitSuccess;

  const CompanySettingsState({
    this.companyName = '',
    this.avatarUrl,
    this.isLoadingProfile = false,
    this.isSavingProfile = false,
    this.profileError,
    this.profileSaveSuccess = false,
    this.savedRating,
    this.isSubmittingRating = false,
    this.ratingError,
    this.ratingSubmitSuccess = false,
  });

  CompanySettingsState copyWith({
    String? companyName,
    String? avatarUrl,
    bool clearAvatar = false,
    bool? isLoadingProfile,
    bool? isSavingProfile,
    String? profileError,
    bool? profileSaveSuccess,
    AppRatingModel? savedRating,
    bool? isSubmittingRating,
    String? ratingError,
    bool? ratingSubmitSuccess,
  }) {
    return CompanySettingsState(
      companyName: companyName ?? this.companyName,
      avatarUrl: clearAvatar ? null : (avatarUrl ?? this.avatarUrl),
      isLoadingProfile: isLoadingProfile ?? this.isLoadingProfile,
      isSavingProfile: isSavingProfile ?? this.isSavingProfile,
      profileError: profileError,
      profileSaveSuccess: profileSaveSuccess ?? false,
      savedRating: savedRating ?? this.savedRating,
      isSubmittingRating: isSubmittingRating ?? this.isSubmittingRating,
      ratingError: ratingError,
      ratingSubmitSuccess: ratingSubmitSuccess ?? false,
    );
  }
}
