import 'package:flutter_bloc/flutter_bloc.dart';
import '../../home/manager/user_home_cubit.dart';
import '../data/repos/points_repo.dart';
import 'points_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PointsCubit extends Cubit<PointsState> {
  final PointsRepo pointsRepo;
  final SharedPreferences sharedPrefs;

  PointsCubit({required this.pointsRepo, required this.sharedPrefs})
    : super(PointsInitial());

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

        //
        await userHomeCubit.getUserData();

        emit(PointsClaimCelebration(10));
      } else {
        //
        await sharedPrefs.setString("last_celebration_date", todayLocal);
        //
        emit(PointsClaimAlreadyClaimed());
      }
    });
  }
}
