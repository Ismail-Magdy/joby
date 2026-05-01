import 'package:dartz/dartz.dart';

abstract class PointsRepo {
  Future<Either<String, dynamic>> claimDailyPoints(String localDate);
}
