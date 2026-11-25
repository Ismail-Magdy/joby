import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'points_repo.dart';
import '../../../../../core/errors/error_handler.dart';

class PointsRepoImpl implements PointsRepo {
  final SupabaseClient supabaseClient;

  PointsRepoImpl({required this.supabaseClient});

  final StreamController<int> _pointsController =
      StreamController<int>.broadcast();
  int? _currentCachedPoints;

  @override
  Stream<int> get pointsStream => _pointsController.stream;

  @override
  int? get currentCachedPoints => _currentCachedPoints;

  @override
  void updatePointsCache(int totalPoints) {
    _currentCachedPoints = totalPoints;
    if (!_pointsController.isClosed) {
      _pointsController.add(totalPoints);
    }
  }

  @override
  Future<Either<String, dynamic>> claimDailyPoints(String localDate) async {
    try {
      final response = await supabaseClient.rpc(
        "claim_daily_points",
        params: {'p_local_date': localDate},
      );
      if (response == true) {
        await fetchTotalPoints();
      }
      return Right(response);
    } catch (error) {
      return Left(ErrorHandler.handleError(error));
    }
  }

  @override
  Future<Either<String, int>> addPoints(int pointsToAdd) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        return const Left("User is not authenticated");
      }

      final data = await supabaseClient
          .from("seekers")
          .select("total_points")
          .eq("id", userId)
          .single();

      final currentPoints = (data["total_points"] as num?)?.toInt() ?? 0;
      final newTotalPoints = currentPoints + pointsToAdd;

      await supabaseClient
          .from("seekers")
          .update({"total_points": newTotalPoints})
          .eq("id", userId);

      updatePointsCache(newTotalPoints);
      return Right(newTotalPoints);
    } catch (error) {
      return Left(ErrorHandler.handleError(error));
    }
  }

  @override
  Future<Either<String, int>> fetchTotalPoints() async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        return const Left("User is not authenticated");
      }

      final data = await supabaseClient
          .from("seekers")
          .select("total_points")
          .eq("id", userId)
          .single();

      final points = (data["total_points"] as num?)?.toInt() ?? 0;
      updatePointsCache(points);
      return Right(points);
    } catch (error) {
      return Left(ErrorHandler.handleError(error));
    }
  }
}
