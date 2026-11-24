import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:joby/features/users/games/data/repos/games_repo.dart';
import '../../home/manager/user_home_cubit.dart';
import '../data/models/game_cooldown_status.dart';
import 'games_state.dart';

class GamesCubit extends Cubit<GamesState> {
  final GamesRepo gamesRepo;

  GamesCubit({required this.gamesRepo}) : super(GamesInitial());

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

        // Reload state to update cooldowns
        await loadGames();
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
}
