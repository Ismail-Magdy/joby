import "package:dartz/dartz.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import "../../../user_info/data/models/user_info_model.dart";
import "user_home_repo.dart";
import "../../../../../core/errors/error_handler.dart";

class UserHomeRepoImpl implements UserHomeRepo {
  final SupabaseClient supabaseClient;

  UserHomeRepoImpl({required this.supabaseClient});

  @override
  Future<Either<String, UserInfoModel>> getUserProfile() async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;

      if (userId == null) {
        return const Left("User not found");
      }

      final data = await supabaseClient
          .from("users")
          .select()
          .eq("id", userId)
          .single();

      return Right(UserInfoModel.fromJson(data));
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
        return const Left("User not found");
      }

      await supabaseClient
          .from("users")
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
