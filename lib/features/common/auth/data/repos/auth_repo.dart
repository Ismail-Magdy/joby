import "package:dartz/dartz.dart";
import "../models/auth_credentials.dart";
import "../models/user_model.dart";

abstract class AuthRepo {
  Future<Either<String, UserModel>> signUpWithEmail(
    AuthCredentials credentials,
  );
  //
  Future<Either<String, UserModel>> signInWithEmail(
    AuthCredentials credentials,
  );
  //
  Future<Either<String, UserModel>> signInWithGoogle();
  //
  Future<void> signOut();
  //
  Future<String> getUserRole();
}
