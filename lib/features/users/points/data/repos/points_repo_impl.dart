import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'points_repo.dart';
import '../../../../../core/errors/error_handler.dart';

class PointsRepoImpl implements PointsRepo {
  final SupabaseClient supabaseClient;

  PointsRepoImpl({required this.supabaseClient});

  @override
  Future<Either<String, dynamic>> claimDailyPoints() async {
    try {
      final response = await supabaseClient.rpc("claim_daily_points");
      return Right(response);
    } catch (error) {
      return Left(ErrorHandler.handleError(error));
    }
  }
}
