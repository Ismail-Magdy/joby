import 'package:dartz/dartz.dart';

abstract class PointsRepo {
  Stream<int> get pointsStream;

  int? get currentCachedPoints;

  void updatePointsCache(int totalPoints);

  Future<Either<String, dynamic>> claimDailyPoints(String localDate);

  Future<Either<String, int>> addPoints(int pointsToAdd);

  Future<Either<String, int>> fetchTotalPoints();
}
