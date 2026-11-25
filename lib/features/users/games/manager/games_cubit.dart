import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:joby/core/di/dependency_injection.dart';
import 'package:joby/features/users/games/data/repos/games_repo.dart';
import 'package:joby/features/users/notification/services/local_notification_service.dart';
import 'package:joby/features/users/points/data/repos/points_repo.dart';
import '../../home/manager/user_home_cubit.dart';
import '../data/models/game_cooldown_status.dart';
import 'games_state.dart';

class GamesCubit extends Cubit<GamesState> {
  final GamesRepo gamesRepo;
  final PointsRepo pointsRepo;
  StreamSubscription<int>? _pointsSubscription;

  GamesCubit({required this.gamesRepo, required this.pointsRepo})
    : super(GamesInitial()) {
    _pointsSubscription = pointsRepo.pointsStream.listen(_onPointsUpdated);
  }

  void _onPointsUpdated(int newTotalPoints) {
    if (isClosed) return;
    final currentState = state;
    if (currentState is GamesLoaded &&
        currentState.userTotalPoints != newTotalPoints) {
      emit(
        GamesLoaded(
          games: currentState.games,
          cooldowns: currentState.cooldowns,
          userTotalPoints: newTotalPoints,
        ),
      );
    }
  }

  /// Loads the games catalog, cooldowns, and user points
  Future<void> loadGames() async {
    emit(GamesLoading());

    final games = gamesRepo.getAvailableGames();
    final cooldownResult = await gamesRepo.getCooldownStatuses();
    final pointsResult = await gamesRepo.getUserTotalPoints();

    Map<String, GameCooldownStatus> cooldownMap = {};
    int totalPoints = 0;

    cooldownResult.fold(
      (error) => emit(GamesError(error)),
      (map) => cooldownMap = map,
    );

    if (state is GamesError) return;

    pointsResult.fold(
      (error) => emit(GamesError(error)),
      (pts) => totalPoints = pts,
    );

    if (state is GamesError) return;

    emit(
      GamesLoaded(
        games: games,
        cooldowns: cooldownMap,
        userTotalPoints: totalPoints,
      ),
    );
  }

  /// Claims points won from playing a mini-game
  Future<bool> claimReward({
    required String gameId,
    required int pointsEarned,
    UserHomeCubit? userHomeCubit,
  }) async {
    if (pointsEarned <= 0) return false;

    emit(GameRewardClaiming(gameId));

    final result = await gamesRepo.awardGamePoints(
      gameId: gameId,
      pointsEarned: pointsEarned,
    );

    return result.fold(
      (error) {
        emit(GamesError(error));
        return false;
      },
      (newTotalPoints) async {
        // Refresh home cubit profile so total points match across all screens
        if (userHomeCubit != null) {
          await userHomeCubit.getUserData();
        }

        emit(
          GameRewardClaimed(
            gameId: gameId,
            pointsEarned: pointsEarned,
            newTotalPoints: newTotalPoints,
          ),
        );

        // Reload state to update cooldowns & sync smart notifications
        await loadGames();
        await getIt<LocalNotificationService>().syncUserNotifications();
        return true;
      },
    );
  }

  /// Checks if a specific game is available
  bool isGameAvailable(String gameId) {
    if (state is GamesLoaded) {
      final loaded = state as GamesLoaded;
      final status = loaded.cooldowns[gameId];
      return status?.isAvailable ?? true;
    }
    return true;
  }

  @override
  Future<void> close() {
    _pointsSubscription?.cancel();
    return super.close();
  }
}
