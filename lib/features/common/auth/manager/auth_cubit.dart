import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/auth_credentials.dart';
import '../data/repos/auth_repo.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo authRepo;

  AuthCubit({required this.authRepo}) : super(AuthInitial());

  // signIn With Email
  Future<void> signInWithEmail(String email, String password) async {
    emit(AuthLoading());

    final credentials = AuthCredentials(email: email, password: password);
    final result = await authRepo.signInWithEmail(credentials);

    result.fold(
      (errorMessage) => emit(AuthError(errorMessage)),
      (user) => emit(AuthSuccess(user)),
    );
  }

  // signUp With Email
  Future<void> signUpWithEmail(
    String email,
    String password,
    String name,
  ) async {
    emit(AuthLoading());

    final credentials = AuthCredentials(
      email: email,
      password: password,
      name: name,
    );
    final result = await authRepo.signUpWithEmail(credentials);

    result.fold(
      (errorMessage) => emit(AuthError(errorMessage)),
      (user) => emit(AuthSuccess(user)),
    );
  }

  // signIn With Google
  Future<void> signInWithGoogle() async {
    emit(AuthLoading());

    final result = await authRepo.signInWithGoogle();

    result.fold(
      (errorMessage) => emit(AuthError(errorMessage)),
      (user) => emit(AuthSuccess(user)),
    );
  }

  // signOut
  Future<void> signOut() async {
    await authRepo.signOut();
    emit(AuthInitial());
  }
}
