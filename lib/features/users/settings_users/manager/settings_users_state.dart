import '../data/models/app_rating_model.dart';

class SettingsUsersState {
  final bool isVisible;
  final bool isDailyNotificationsEnabled;
  final bool isUpdatingVisibility;
  final bool isSubmittingRating;
  final AppRatingModel? savedRating;
  final String? visibilityError;
  final String? ratingError;
  final bool ratingSubmitSuccess;

  const SettingsUsersState({
    this.isVisible = true,
    this.isDailyNotificationsEnabled = true,
    this.isUpdatingVisibility = false,
    this.isSubmittingRating = false,
    this.savedRating,
    this.visibilityError,
    this.ratingError,
    this.ratingSubmitSuccess = false,
  });

  SettingsUsersState copyWith({
    bool? isVisible,
    bool? isDailyNotificationsEnabled,
    bool? isUpdatingVisibility,
    bool? isSubmittingRating,
    AppRatingModel? savedRating,
    bool clearSavedRating = false,
    String? visibilityError,
    String? ratingError,
    bool? ratingSubmitSuccess,
  }) {
    return SettingsUsersState(
      isVisible: isVisible ?? this.isVisible,
      isDailyNotificationsEnabled:
          isDailyNotificationsEnabled ?? this.isDailyNotificationsEnabled,
      isUpdatingVisibility: isUpdatingVisibility ?? this.isUpdatingVisibility,
      isSubmittingRating: isSubmittingRating ?? this.isSubmittingRating,
      savedRating: clearSavedRating ? null : (savedRating ?? this.savedRating),
      visibilityError: visibilityError,
      ratingError: ratingError,
      ratingSubmitSuccess: ratingSubmitSuccess ?? false,
    );
  }
}
