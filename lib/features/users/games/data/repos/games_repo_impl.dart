import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/errors/error_handler.dart';
import '../../../../../core/routes/routes.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../points/data/repos/points_repo.dart';
import '../models/game_cooldown_status.dart';
import '../models/mini_game_model.dart';
import 'games_repo.dart';

class GamesRepoImpl implements GamesRepo {
  final SupabaseClient supabaseClient;
  final SharedPreferences sharedPrefs;
  final PointsRepo pointsRepo;

  static const String _prefPrefix = "joby_game_last_played_";

  GamesRepoImpl({
    required this.supabaseClient,
    required this.sharedPrefs,
    required this.pointsRepo,
  });

  @override
  List<MiniGameModel> getAvailableGames() {
    return const [
      //
      MiniGameModel(
        id: "spin_wheel",
        title: "Spin & Win",
        subtitle: "Spin The Joby Wheel Of Fortune For Instant Points",
        badge: "DAILY LUCK",
        icon: "assets/images/spin_win.jpeg",
        maxRewardPoints: 50,
        cooldownDuration: Duration(hours: 18),
        primaryColor: AppColors.primaryColor,
        secondaryColor: Color(0xFF64B5F6),
        routeName: Routes.spinWheelGameScreen,
      ),
      //
      MiniGameModel(
        id: "catch_logo",
        title: "Catch The Logo",
        subtitle: "Catch Falling Joby Logos Before Time Expires",
        badge: "FAST REFLEX",
        icon: "assets/images/catch_the_logo.jpeg",
        maxRewardPoints: 40,
        cooldownDuration: Duration(hours: 18),
        primaryColor: AppColors.primaryColor,
        secondaryColor: Color(0xFF64B5F6),
        routeName: Routes.catchLogoGameScreen,
      ),
      //
      MiniGameModel(
        id: "memory_match",
        title: "Memory Match",
        subtitle: "Flip and Pair Joby Recruitment Cards To Boost Your Brain",
        badge: "BRAIN BOOST",
        icon: "assets/images/memory_match.jpeg",
        maxRewardPoints: 45,
        cooldownDuration: Duration(hours: 18),
        primaryColor: AppColors.primaryColor,
        secondaryColor: Color(0xFF64B5F6),
        routeName: Routes.memoryMatchGameScreen,
      ),
      //
      MiniGameModel(
        id: "logo_puzzle",
        title: "Logo Puzzle",
        subtitle:
            "Slide numbered tiles to reconstruct the official Joby emblem",
        badge: "LOGIC PUZZLE",
        icon: "assets/images/logo_puzzle.jpeg",
        maxRewardPoints: 50,
        cooldownDuration: Duration(hours: 18),
        primaryColor: AppColors.primaryColor,
        secondaryColor: Color(0xFF64B5F6),
        routeName: Routes.logoPuzzleGameScreen,
      ),
      //
    ];
  }

  @override
  Future<Either<String, Map<String, GameCooldownStatus>>>
  getCooldownStatuses() async {
    try {
      final games = getAvailableGames();
      final Map<String, GameCooldownStatus> statusMap = {};

      for (final game in games) {
        final lastPlayedStr = sharedPrefs.getString("$_prefPrefix${game.id}");
        DateTime? lastPlayed;
        if (lastPlayedStr != null) {
          lastPlayed = DateTime.tryParse(lastPlayedStr);
        }

        statusMap[game.id] = GameCooldownStatus(
          gameId: game.id,
          lastPlayedAt: lastPlayed,
          cooldownDuration: game.cooldownDuration,
        );
      }

      return Right(statusMap);
    } catch (e) {
      return Left(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<String, int>> awardGamePoints({
    required String gameId,
    required int pointsEarned,
  }) async {
    final result = await pointsRepo.addPoints(pointsEarned);
    return result.fold(
      (error) => Left(error),
      (newTotalPoints) async {
        // Record cooldown locally in SharedPreferences
        await sharedPrefs.setString(
          "$_prefPrefix$gameId",
          DateTime.now().toIso8601String(),
        );
        return Right(newTotalPoints);
      },
    );
  }

  @override
  Future<Either<String, int>> getUserTotalPoints() {
    return pointsRepo.fetchTotalPoints();
  }
}
