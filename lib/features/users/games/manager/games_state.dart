import '../data/models/game_cooldown_status.dart';
import '../data/models/mini_game_model.dart';

abstract class GamesState {}

class GamesInitial extends GamesState {}

class GamesLoading extends GamesState {}

class GamesLoaded extends GamesState {
  final List<MiniGameModel> games;
  final Map<String, GameCooldownStatus> cooldowns;
  final int userTotalPoints;

  GamesLoaded({
    required this.games,
    required this.cooldowns,
    required this.userTotalPoints,
  });

  GamesLoaded copyWith({
    List<MiniGameModel>? games,
    Map<String, GameCooldownStatus>? cooldowns,
    int? userTotalPoints,
  }) {
    return GamesLoaded(
      games: games ?? this.games,
      cooldowns: cooldowns ?? this.cooldowns,
      userTotalPoints: userTotalPoints ?? this.userTotalPoints,
    );
  }
}

class GameRewardClaiming extends GamesState {
  final String gameId;
  GameRewardClaiming(this.gameId);
}

class GameRewardClaimed extends GamesState {
  final String gameId;
  final int pointsEarned;
  final int newTotalPoints;

  GameRewardClaimed({
    required this.gameId,
    required this.pointsEarned,
    required this.newTotalPoints,
  });
}

class GamesError extends GamesState {
  final String message;
  GamesError(this.message);
}
