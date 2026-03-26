import "../data/models/user_model.dart";

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final UserModel user;
  final bool hasProfile;
  final String userType;

  AuthSuccess({
    required this.user,
    required this.hasProfile,
    required this.userType,
  });
}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);
}
