import 'package:flutter/foundation.dart';
import "package:dartz/dartz.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import "package:google_sign_in/google_sign_in.dart";
import "../models/auth_credentials.dart";
import "../models/user_model.dart";
import "auth_repo.dart";
import "../../../../../core/errors/error_handler.dart";

class AuthRepoImpl implements AuthRepo {
  final SupabaseClient supabaseClient;

  final String webClientId =
      "39044447018-cclr5gn2dp3spu93uvqrg2as3o32er25.apps.googleusercontent.com";
  final String iosClientId =
      "39044447018-nefhnuaomgem3velpbl5hcue5c8n1j41.apps.googleusercontent.com";

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
          return const Left("An account with this email already exists");
        }
        return Right(UserModel.fromSupabase(response.user!));
      } else {
        return const Left("Sign up failed. Please try again");
      }
    } catch (e) {
      return Left(ErrorHandler.handleError(e));
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
        return const Left("Sign in failed. Check your credentials");
      }
    } catch (e) {
      return Left(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<String, UserModel>> signInWithGoogleQuick() async {
    try {
      final googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return const Left("Google sign in was canceled");
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
        return const Left("Google sign in failed");
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
        return const Left("Google sign in was canceled");
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
        return const Left("Google sign in failed");
      }
    } catch (error) {
      return Left(ErrorHandler.handleError(error));
    }
  }

  @override
  Future<void> signOut() async {
    await supabaseClient.auth.signOut();

    try {
      await _googleSignIn.signOut();
      await _googleSignIn.disconnect();
    } catch (error) {
      debugPrint("Google SignOut Error: ${ErrorHandler.handleError(error)}");
    }
  }

  @override
  Future<String> getUserRole() async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) return "none";

      final seekerData = await supabaseClient
          .from("users")
          .select("id")
          .eq("id", userId)
          .maybeSingle();

      if (seekerData != null) return "seeker";

      final managerData = await supabaseClient
          .from("managers_data")
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
