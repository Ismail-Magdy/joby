import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:joby/features/users/notification/services/local_notification_service.dart';
import '../data/models/app_rating_model.dart';
import '../data/repos/settings_users_repo.dart';
import 'settings_users_state.dart';

class SettingsUsersCubit extends Cubit<SettingsUsersState> {
  final SettingsUsersRepo settingsUsersRepo;
  final LocalNotificationService notificationService;

  SettingsUsersCubit({
    required this.settingsUsersRepo,
    required this.notificationService,
  }) : super(const SettingsUsersState());

  Future<void> loadSettings() async {
    // Emit cached values immediately for instant UI rendering
    emit(
      state.copyWith(
        isVisible: settingsUsersRepo.getCachedProfileVisibility(),
        isDailyNotificationsEnabled: settingsUsersRepo
            .getDailyNotificationsEnabled(),
      ),
    );

    final visibilityResult = await settingsUsersRepo.fetchProfileVisibility();
    visibilityResult.fold((_) {}, (isVisible) {
      if (!isClosed) {
        emit(state.copyWith(isVisible: isVisible));
      }
    });

    final ratingResult = await settingsUsersRepo.getUserRating();
    ratingResult.fold((_) {}, (rating) {
      if (!isClosed && rating != null) {
        emit(state.copyWith(savedRating: rating));
      }
    });
  }

  Future<void> toggleProfileVisibility(bool newValue) async {
    final previousValue = state.isVisible;
    emit(
      state.copyWith(
        isVisible: newValue,
        isUpdatingVisibility: true,
        visibilityError: null,
      ),
    );

    final result = await settingsUsersRepo.updateProfileVisibility(newValue);
    if (isClosed) return;

    result.fold(
      (error) {
        emit(
          state.copyWith(
            isVisible: previousValue,
            isUpdatingVisibility: false,
            visibilityError: error,
          ),
        );
      },
      (_) {
        emit(state.copyWith(isVisible: newValue, isUpdatingVisibility: false));
      },
    );
  }

  Future<void> toggleDailyNotifications(bool enabled) async {
    emit(state.copyWith(isDailyNotificationsEnabled: enabled));
    await settingsUsersRepo.setDailyNotificationsEnabled(enabled);

    if (enabled) {
      await notificationService.syncUserNotifications(
        requestPermissionIfNeeded: true,
      );
    } else {
      await notificationService.cancelAllNotifications();
    }
  }

  Future<void> submitRating({required int rating, String? comment}) async {
    if (state.savedRating != null) return;
    emit(state.copyWith(isSubmittingRating: true, ratingError: null));

    final result = await settingsUsersRepo.submitAppRating(
      rating: rating,
      comment: comment,
    );
    if (isClosed) return;

    result.fold(
      (error) {
        emit(state.copyWith(isSubmittingRating: false, ratingError: error));
      },
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
