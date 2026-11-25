import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:joby/core/di/dependency_injection.dart';
import 'package:joby/features/users/notification/services/local_notification_service.dart';
import '../../home/manager/user_home_cubit.dart';
import '../data/repos/points_repo.dart';
import 'points_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PointsCubit extends Cubit<PointsState> {
  final PointsRepo pointsRepo;
  final SharedPreferences sharedPrefs;
  StreamSubscription<int>? _pointsSubscription;

  PointsCubit({required this.pointsRepo, required this.sharedPrefs})
    : super(PointsInitial()) {
    _pointsSubscription = pointsRepo.pointsStream.listen((totalPoints) {
      if (!isClosed) {
        emit(PointsTotalUpdated(totalPoints));
      }
    });
  }

  Future<void> claimDailyPoints(UserHomeCubit userHomeCubit) async {
    final todayLocal = DateTime.now().toIso8601String().substring(0, 10);
    final lastCelebrated = sharedPrefs.getString("last_celebration_date");

    //
    if (lastCelebrated == todayLocal) {
      return;
    }

    emit(PointsLoading());

    //
    final result = await pointsRepo.claimDailyPoints(todayLocal);

    result.fold((errorMessage) => emit(PointsClaimError(errorMessage)), (
      response,
    ) async {
      //
      if (response == true) {
        //
        await sharedPrefs.setString("last_celebration_date", todayLocal);
        await _updateDailyStreak(todayLocal);

        //
        await userHomeCubit.getUserData();
        await getIt<LocalNotificationService>().syncUserNotifications();

        emit(PointsClaimCelebration(10));
      } else {
        //
        await sharedPrefs.setString("last_celebration_date", todayLocal);
        await getIt<LocalNotificationService>().syncUserNotifications();
        //
        emit(PointsClaimAlreadyClaimed());
      }
    });
  }

  Future<void> _updateDailyStreak(String todayLocal) async {
    final lastStreakDateStr = sharedPrefs.getString(
      LocalNotificationService.dailyStreakLastDateKey,
    );
    final currentStreak =
        sharedPrefs.getInt(LocalNotificationService.dailyStreakCountKey) ?? 0;

    int nextStreak = 1;
    if (lastStreakDateStr != null) {
      if (lastStreakDateStr == todayLocal) {
        nextStreak = currentStreak > 0 ? currentStreak : 1;
      } else {
        final lastDate = DateTime.tryParse(lastStreakDateStr);
        final todayDate = DateTime.tryParse(todayLocal);
        if (lastDate != null &&
            todayDate != null &&
            todayDate.difference(lastDate).inDays == 1) {
          nextStreak = currentStreak + 1;
        }
      }
    }

    await sharedPrefs.setInt(
      LocalNotificationService.dailyStreakCountKey,
      nextStreak,
    );
    await sharedPrefs.setString(
      LocalNotificationService.dailyStreakLastDateKey,
      todayLocal,
    );
  }

  @override
  Future<void> close() {
    _pointsSubscription?.cancel();
    return super.close();
  }
}
