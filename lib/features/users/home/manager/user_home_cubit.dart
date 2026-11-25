import "package:flutter_bloc/flutter_bloc.dart";
import "package:joby/core/di/dependency_injection.dart";
import "package:joby/features/users/notification/services/local_notification_service.dart";
import "../data/repos/user_home_repo.dart";
import "user_home_state.dart";

class UserHomeCubit extends Cubit<UserHomeState> {
  final UserHomeRepo userHomeRepo;

  UserHomeCubit({required this.userHomeRepo}) : super(UserHomeInitial());

  Future<void> getUserData() async {
    emit(UserHomeLoading());

    final result = await userHomeRepo.getUserProfile();

    result.fold((errorMessage) => emit(UserHomeError(errorMessage)), (
      userInfo,
    ) {
      getIt<LocalNotificationService>().syncUserNotifications(
        userInfo: userInfo,
      );
      emit(UserHomeSuccess(userInfo));
    });
  }

  Future<String?> updateUserLocation({
    required double latitude,
    required double longitude,
    required String locationName,
  }) async {
    final result = await userHomeRepo.updateUserLocation(
      latitude: latitude,
      longitude: longitude,
      locationName: locationName,
    );

    return result.fold(
      (errorMessage) => errorMessage, // Return error message if it fails
      (_) {
        getUserData(); // Refresh the profile quietly
        return null; // Null means success
      },
    );
  }
}
