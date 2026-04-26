import 'package:flutter_bloc/flutter_bloc.dart';
import '../../home/manager/user_home_cubit.dart';
import '../../home/manager/user_home_state.dart';
import '../data/repos/points_repo.dart';
import 'points_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PointsCubit extends Cubit<PointsState> {
  final PointsRepo pointsRepo;
  final SharedPreferences sharedPrefs;

  bool _hasAttemptedClaim = false;

  PointsCubit({required this.pointsRepo, required this.sharedPrefs})
    : super(PointsInitial());

  Future<void> claimDailyPoints(UserHomeCubit userHomeCubit) async {
    if (_hasAttemptedClaim) return;
    _hasAttemptedClaim = true;

    final todayLocal = DateTime.now().toIso8601String().substring(0, 10);
    final lastCelebrated = sharedPrefs.getString("last_celebration_date");

    // If already celebrated locally today, strictly halt execution to prevent endlessly granting points
    if (lastCelebrated == todayLocal) {
      return;
    }

    emit(PointsLoading());

    // 1. Get current state to find old points
    int oldPoints = 0;
    if (userHomeCubit.state is UserHomeSuccess) {
      oldPoints = (userHomeCubit.state as UserHomeSuccess).userInfo.totalPoints;
    }

    // 2. Call RPC
    final result = await pointsRepo.claimDailyPoints();
    result.fold((errorMessage) => emit(PointsClaimError(errorMessage)), (
      response,
    ) async {
      // 3. Re-fetch user data to get accurate new points from database
      await userHomeCubit.getUserData();

      int newPoints = oldPoints; // default fallback
      if (userHomeCubit.state is UserHomeSuccess) {
        newPoints =
            (userHomeCubit.state as UserHomeSuccess).userInfo.totalPoints;
      }

      // 4. Determine if points actually went up
      if (newPoints > oldPoints) {
        await sharedPrefs.setString("last_celebration_date", todayLocal);
        emit(PointsClaimCelebration(newPoints - oldPoints));
      } else {
        emit(PointsClaimAlreadyClaimed());
      }
    });
  }
}
