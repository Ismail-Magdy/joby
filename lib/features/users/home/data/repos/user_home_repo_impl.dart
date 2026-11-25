import "package:dartz/dartz.dart";
import "package:joby/features/users/points/data/repos/points_repo.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import "../../../user_info/data/models/user_info_model.dart";
import "user_home_repo.dart";
import "../../../../../core/errors/error_handler.dart";

class UserHomeRepoImpl implements UserHomeRepo {
  final SupabaseClient supabaseClient;
  final PointsRepo pointsRepo;

  UserHomeRepoImpl({
    required this.supabaseClient,
    required this.pointsRepo,
  });

  @override
  Future<Either<String, UserInfoModel>> getUserProfile() async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;

      if (userId == null) {
        return const Left("User Not Found");
      }

      final data = await supabaseClient
          .from("seekers")
          .select()
          .eq("id", userId)
          .single();

      final userInfo = UserInfoModel.fromJson(data);
      pointsRepo.updatePointsCache(userInfo.totalPoints);
      return Right(userInfo);
    } catch (error) {
      return Left(ErrorHandler.handleError(error));
    }
  }

  @override
  Future<Either<String, void>> updateUserLocation({
    required double latitude,
    required double longitude,
    required String locationName,
  }) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;

      if (userId == null) {
        return const Left("User Not Found");
      }

      await supabaseClient
          .from("seekers")
          .update({
            "latitude": latitude,
            "longitude": longitude,
            "location_name": locationName,
          })
          .eq("id", userId);

      return const Right(null);
    } catch (error) {
      return Left(ErrorHandler.handleError(error));
    }
  }
}
