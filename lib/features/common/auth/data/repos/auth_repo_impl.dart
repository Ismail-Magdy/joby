import "package:dartz/dartz.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import "package:google_sign_in/google_sign_in.dart";
import "../models/auth_credentials.dart";
import "../models/user_model.dart";
import "auth_repo.dart";

class AuthRepoImpl implements AuthRepo {
  final SupabaseClient supabaseClient;

  final String webClientId =
      "39044447018-cclr5gn2dp3spu93uvqrg2as3o32er25.apps.googleusercontent.com";
  final String iosClientId =
      "39044447018-nefhnuaomgem3velpbl5hcue5c8n1j41.apps.googleusercontent.com";

  AuthRepoImpl({required this.supabaseClient});

  @override
  Future<Either<String, UserModel>> signUpWithEmail(
    AuthCredentials credentials,
  ) async {
    try {
      final AuthResponse response = await supabaseClient.auth.signUp(
        email: credentials.email,
        password: credentials.password,
        data: {"name": credentials.name},
      );

      if (response.user != null) {
        return Right(UserModel.fromSupabase(response.user!));
      } else {
        return const Left("Sign up failed. Please try again.");
      }
    } on AuthException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left("An unexpected error occurred: $e");
    }
  }

  @override
  Future<Either<String, UserModel>> signInWithEmail(
    AuthCredentials credentials,
  ) async {
    try {
      final AuthResponse response = await supabaseClient.auth
          .signInWithPassword(
            email: credentials.email,
            password: credentials.password,
          );

      if (response.user != null) {
        return Right(UserModel.fromSupabase(response.user!));
      } else {
        return const Left("Sign in failed. Check your credentials.");
      }
    } on AuthException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left("An unexpected error occurred: $e");
    }
  }

  @override
  Future<Either<String, UserModel>> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: iosClientId,
        serverClientId: webClientId,
      );

      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        return const Left("Google sign in was canceled.");
      }

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null || idToken == null) {
        return const Left("Failed to get Google tokens.");
      }

      final AuthResponse response = await supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (response.user != null) {
        return Right(UserModel.fromSupabase(response.user!));
      } else {
        return const Left("Google sign in failed in Supabase.");
      }
    } on AuthException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left("An unexpected error occurred: $e");
    }
  }

  @override
  Future<void> signOut() async {
    await supabaseClient.auth.signOut();
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

      // مستقبلاً لما نعمل جدول للشركات هنشيل الكومنت من هنا
      // final companyData = await supabaseClient.from("companies").select("id").eq("id", userId).maybeSingle();
      // if (companyData != null) return "company";

      return "none";
    } catch (e) {
      return "none";
    }
  }
}
