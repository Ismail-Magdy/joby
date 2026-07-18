import "package:dartz/dartz.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import "feed_back_repo.dart";
import "../../../../../core/errors/error_handler.dart";

class FeedBackRepoImpl implements FeedBackRepo {
  final SupabaseClient supabaseClient;

  FeedBackRepoImpl({required this.supabaseClient});

  @override
  Future<Either<String, Unit>> sendFeedback(String message) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;

      await supabaseClient.from("feedback").insert({
        "user_id": userId,
        "message": message,
      });

      return const Right(unit);
    } catch (error) {
      return Left(ErrorHandler.handleError(error));
    }
  }
}
