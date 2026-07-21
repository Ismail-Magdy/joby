import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repo/forgot_password_repo.dart';
import 'forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  final ForgotPasswordRepo repo;

  ForgotPasswordCubit({required this.repo}) : super(ForgotPasswordInitial());

  Future<void> sendResetEmail(String email) async {
    emit(ForgotPasswordLoading());

    final result = await repo.sendPasswordResetEmail(email);

    result.fold(
      (error) => emit(ForgotPasswordError(error)),
      (_) => emit(ForgotPasswordSuccess()),
    );
  }
}
