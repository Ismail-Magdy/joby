import "package:dartz/dartz.dart";
import "package:joby/core/di/dependency_injection.dart";
import "package:joby/features/users/notification/services/local_notification_service.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import "package:google_sign_in/google_sign_in.dart";
import "../models/auth_credentials.dart";
import "../models/user_model.dart";
import "auth_repo.dart";
import "../../../../../core/errors/error_handler.dart";

class AuthRepoImpl implements AuthRepo {
  final SupabaseClient supabaseClient;

  final String webClientId =
      "202946347612-djmbpgh2k3tv7gd586ucauco7tbi0vfs.apps.googleusercontent.com";
  final String iosClientId =
      "202946347612-60847ll616ifkjjh34l0ujbe5hers2u8.apps.googleusercontent.com";

  late final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: iosClientId,
    serverClientId: webClientId,
  );

  AuthRepoImpl({required this.supabaseClient});

  @override
  Future<Either<String, UserModel>> signUpWithEmail(
    AuthCredentials credentials,
  ) async {
    try {
      final response = await supabaseClient.auth.signUp(
        email: credentials.email,
        password: credentials.password,
        data: {"name": credentials.name},
      );

      if (response.user != null) {
        if (response.user!.identities != null &&
            response.user!.identities!.isEmpty) {
          return const Left("An Account With This Email Already Exists");
        }
        return Right(UserModel.fromSupabase(response.user!));
      } else {
        return const Left("Sign Up Failed");
      }
    } catch (error) {
      return Left(ErrorHandler.handleError(error));
    }
  }

  @override
  Future<Either<String, UserModel>> signInWithEmail(
    AuthCredentials credentials,
  ) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        email: credentials.email,
        password: credentials.password,
      );

      if (response.user != null) {
        return Right(UserModel.fromSupabase(response.user!));
      } else {
        return const Left("Sign In Failed");
      }
    } catch (error) {
      return Left(ErrorHandler.handleError(error));
    }
  }

  @override
  Future<Either<String, UserModel>> signInWithGoogleQuick() async {
    try {
      final googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return const Left("Google Sign In Was Canceled");
      }

      final googleAuth = await googleUser.authentication;

      final response = await supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken!,
      );

      if (response.user != null) {
        return Right(UserModel.fromSupabase(response.user!));
      } else {
        return const Left("Google Sign In Failed");
      }
    } catch (error) {
      return Left(ErrorHandler.handleError(error));
    }
  }

  @override
  Future<Either<String, UserModel>> signInWithGoogleChooseAccount() async {
    try {
      await _googleSignIn.disconnect();

      final googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return const Left("Google Sign In Was Canceled");
      }

      final googleAuth = await googleUser.authentication;

      final response = await supabaseClient.auth.signInWithIdToken(
        provider: .google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken!,
      );

      if (response.user != null) {
        return Right(UserModel.fromSupabase(response.user!));
      } else {
        return const Left("Google Sign In Failed");
      }
    } catch (error) {
      return Left(ErrorHandler.handleError(error));
    }
  }

  @override
  Future<void> signOut() async {
    await getIt<LocalNotificationService>().cancelAllNotifications();
    await supabaseClient.auth.signOut();

    await _googleSignIn.signOut();
    await _googleSignIn.disconnect();
  }

  @override
  Future<String> getUserRole() async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) return "none";

      final seekerData = await supabaseClient
          .from("seekers")
          .select("id")
          .eq("id", userId)
          .maybeSingle();

      if (seekerData != null) return "seeker";

      final managerData = await supabaseClient
          .from("companies")
          .select("id")
          .eq("id", userId)
          .maybeSingle();

      if (managerData != null) return "company";

      return "none";
    } catch (error) {
      return "none";
    }
  }
}
