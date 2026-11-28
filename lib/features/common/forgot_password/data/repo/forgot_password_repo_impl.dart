import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'forgot_password_repo.dart';
import '../../../../../core/errors/error_handler.dart';

class ForgotPasswordRepoImpl implements ForgotPasswordRepo {
  final SupabaseClient supabaseClient;

  ForgotPasswordRepoImpl({required this.supabaseClient});

  @override
  Future<Either<String, void>> sendPasswordResetEmail(String email) async {
    try {
      final isEmailExists = await supabaseClient.rpc(
        'check_email_exists',
        params: {'p_email': email},
      );

      if (isEmailExists == false) {
        return const Left(
          "This Email is Not Registered, Please Check Again or Sign Up",
        );
      }

      await supabaseClient.auth.resetPasswordForEmail(email);

      return const Right(null);
    } catch (error) {
      return Left(ErrorHandler.handleError(error));
    }
  }
}
