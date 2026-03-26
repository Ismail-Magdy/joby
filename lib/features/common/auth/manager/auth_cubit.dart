import "package:flutter_bloc/flutter_bloc.dart";
import "../data/models/auth_credentials.dart";
import "../data/repos/auth_repo.dart";
import "auth_state.dart";
import "package:joby/core/helpers/shared_prefrences_helper.dart";

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo authRepo;

  AuthCubit({required this.authRepo}) : super(AuthInitial());

  Future<void> signInWithEmail(String email, String password) async {
    emit(AuthLoading());

    final credentials = AuthCredentials(email: email, password: password);
    final result = await authRepo.signInWithEmail(credentials);

    result.fold((errorMessage) => emit(AuthError(errorMessage)), (user) async {
      final dbRole = await authRepo.getUserRole();
      final selectedRole = await SharedPrefHelper.getString("userType");

      if (dbRole != "none" && dbRole != selectedRole) {
        await authRepo.signOut();
        final roleName = dbRole == "seeker" ? "Job Seeker" : "Company";
        emit(
          AuthError(
            "This email is already registered as a $roleName. Please log in from the correct section.",
          ),
        );
        return;
      }

      if (dbRole != "none") {
        await SharedPrefHelper.setData("isUserInfoCompleted", true);
      }

      emit(
        AuthSuccess(
          user: user,
          hasProfile: dbRole != "none",
          userType: selectedRole,
        ),
      );
    });
  }

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

    result.fold((errorMessage) => emit(AuthError(errorMessage)), (user) async {
      final dbRole = await authRepo.getUserRole();
      final selectedRole = await SharedPrefHelper.getString("userType");

      if (dbRole != "none" && dbRole != selectedRole) {
        await authRepo.signOut();
        final roleName = dbRole == "seeker" ? "Job Seeker" : "Company";
        emit(
          AuthError(
            "This email is already registered as a $roleName. Please log in from the correct section.",
          ),
        );
        return;
      }

      if (dbRole != "none") {
        await SharedPrefHelper.setData("isUserInfoCompleted", true);
      }

      emit(
        AuthSuccess(
          user: user,
          hasProfile: dbRole != "none",
          userType: selectedRole,
        ),
      );
    });
  }

  Future<void> signInWithGoogle() async {
    emit(AuthLoading());

    final result = await authRepo.signInWithGoogle();

    result.fold((errorMessage) => emit(AuthError(errorMessage)), (user) async {
      final dbRole = await authRepo.getUserRole();
      final selectedRole = await SharedPrefHelper.getString("userType");

      if (dbRole != "none" && dbRole != selectedRole) {
        await authRepo.signOut();
        final roleName = dbRole == "seeker" ? "Job Seeker" : "Company";
        emit(
          AuthError(
            "This email is already registered as a $roleName. Please log in from the correct section.",
          ),
        );
        return;
      }

      if (dbRole != "none") {
        await SharedPrefHelper.setData("isUserInfoCompleted", true);
      }

      emit(
        AuthSuccess(
          user: user,
          hasProfile: dbRole != "none",
          userType: selectedRole,
        ),
      );
    });
  }

  Future<void> signOut() async {
    await authRepo.signOut();
    emit(AuthInitial());
  }
}
