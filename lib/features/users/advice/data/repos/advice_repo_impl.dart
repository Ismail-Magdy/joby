import "package:dartz/dartz.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import "advice_repo.dart";

class AdviceRepoImpl implements AdviceRepo {
  final SupabaseClient supabaseClient;

  AdviceRepoImpl({required this.supabaseClient});

  @override
  Future<Either<String, Unit>> sendFeedback(String message) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;

      await supabaseClient.from("feedback").insert({
        "user_id": userId,
        "message": message,
      });

      return const Right(unit);
    } on PostgrestException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left("An unexpected error occurred: $e");
    }
  }
}
