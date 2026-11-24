import 'package:dartz/dartz.dart';
import '../models/game_cooldown_status.dart';
import '../models/mini_game_model.dart';

abstract class GamesRepo {
  /// Returns the catalog of supported mini-games
  List<MiniGameModel> getAvailableGames();

  /// Gets the live cooldown status for all games
  Future<Either<String, Map<String, GameCooldownStatus>>> getCooldownStatuses();

  /// Awards points to the user in Supabase and records cooldown
  Future<Either<String, int>> awardGamePoints({
    required String gameId,
    required int pointsEarned,
  });

  /// Fetches current user points from Supabase
  Future<Either<String, int>> getUserTotalPoints();
}
