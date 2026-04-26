import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'points_repo.dart';

class PointsRepoImpl implements PointsRepo {
  final SupabaseClient supabaseClient;

  PointsRepoImpl({required this.supabaseClient});

  @override
  Future<Either<String, dynamic>> claimDailyPoints() async {
    try {
      final response = await supabaseClient.rpc("claim_daily_points");
      return Right(response);
    } on PostgrestException catch (error) {
      return Left(error.message);
    } catch (error) {
      return Left("An unexpected error occurred: $error");
    }
  }
}
