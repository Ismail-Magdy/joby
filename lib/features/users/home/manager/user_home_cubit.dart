import "package:flutter_bloc/flutter_bloc.dart";
import "../data/repos/user_home_repo.dart";
import "user_home_state.dart";

class UserHomeCubit extends Cubit<UserHomeState> {
  final UserHomeRepo userHomeRepo;

  UserHomeCubit({required this.userHomeRepo}) : super(UserHomeInitial());

  Future<void> getUserData() async {
    emit(UserHomeLoading());

    final result = await userHomeRepo.getUserProfile();

    result.fold(
      (errorMessage) => emit(UserHomeError(errorMessage)),
      (userInfo) => emit(UserHomeSuccess(userInfo)),
    );
  }
}
