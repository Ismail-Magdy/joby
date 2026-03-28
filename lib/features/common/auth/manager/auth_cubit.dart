import "package:flutter_bloc/flutter_bloc.dart";
import "../data/models/auth_credentials.dart";
import "../data/repos/auth_repo.dart";
import "auth_state.dart";
import "package:joby/core/helpers/shared_prefrences_helper.dart";

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo authRepo;

  AuthCubit({required this.authRepo}) : super(AuthInitial());

  String? _normalizeRole(String? rawRole) {
    if (rawRole == null || rawRole.isEmpty) return null;

    final lower = rawRole.toLowerCase();
    if (lower.contains("company") || lower.contains("business")) {
      return "company";
    }
    return "seeker";
  }

  Future<void> signInWithEmail(String email, String password) async {
    emit(AuthLoading());

    final credentials = AuthCredentials(email: email, password: password);
    final result = await authRepo.signInWithEmail(credentials);

    result.fold((errorMessage) => emit(AuthError(errorMessage)), (user) async {
      final dbRole = await authRepo.getUserRole();
      final rawRole = await SharedPrefHelper.getString("userType");
      final selectedRole = _normalizeRole(rawRole);

      if (dbRole != "none" && selectedRole != null && dbRole != selectedRole) {
        await authRepo.signOut();
        final roleName = dbRole == "seeker" ? "Job Seeker" : "Company";
        emit(AuthError("This email is already registered as a $roleName."));
        return;
      }

      if (dbRole != "none") {
        await SharedPrefHelper.setData("isUserInfoCompleted", true);
      }

      emit(
        AuthSuccess(
          user: user,
          hasProfile: dbRole != "none",
          userType: dbRole != "none" ? dbRole : (selectedRole ?? "seeker"),
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
      final rawRole = await SharedPrefHelper.getString("userType");
      final selectedRole = _normalizeRole(rawRole);

      if (dbRole != "none" && selectedRole != null && dbRole != selectedRole) {
        await authRepo.signOut();
        final roleName = dbRole == "seeker" ? "Job Seeker" : "Company";
        emit(AuthError("This email is already registered as a $roleName."));
        return;
      }

      if (dbRole != "none") {
        await SharedPrefHelper.setData("isUserInfoCompleted", true);
      }

      emit(
        AuthSuccess(
          user: user,
          hasProfile: dbRole != "none",
          userType: dbRole != "none" ? dbRole : (selectedRole ?? "seeker"),
        ),
      );
    });
  }

  Future<void> signInWithGoogle() async {
    emit(AuthLoading());

    final result = await authRepo.signInWithGoogle();

    result.fold((errorMessage) => emit(AuthError(errorMessage)), (user) async {
      final dbRole = await authRepo.getUserRole();
      final rawRole = await SharedPrefHelper.getString("userType");
      final selectedRole = _normalizeRole(rawRole);

      if (dbRole != "none" && selectedRole != null && dbRole != selectedRole) {
        await authRepo.signOut();
        final roleName = dbRole == "seeker" ? "Job Seeker" : "Company";
        emit(AuthError("This email is already registered as a $roleName."));
        return;
      }

      if (dbRole != "none") {
        await SharedPrefHelper.setData("isUserInfoCompleted", true);
      }

      emit(
        AuthSuccess(
          user: user,
          hasProfile: dbRole != "none",
          userType: dbRole != "none" ? dbRole : (selectedRole ?? "seeker"),
        ),
      );
    });
  }

  Future<void> signOut() async {
    await authRepo.signOut();
    emit(AuthInitial());
  }
}
