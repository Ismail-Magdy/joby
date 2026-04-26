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
}
