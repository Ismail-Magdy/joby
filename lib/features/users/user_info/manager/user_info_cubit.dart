import "dart:io";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:joby/core/helpers/constants.dart";
import "package:joby/core/helpers/shared_prefrences_helper.dart";
import "../data/models/user_info_model.dart";
import "../data/repos/user_info_repo.dart";
import "user_info_state.dart";

class UserInfoCubit extends Cubit<UserInfoState> {
  final UserInfoRepo userInfoRepo;

  UserInfoCubit({required this.userInfoRepo}) : super(UserInfoInitial());

  Future<void> saveUserInfo(
    UserInfoModel userInfo, {
    File? avatarFile,
    File? cvFile,
  }) async {
    emit(UserInfoLoading());

    final result = await userInfoRepo.saveUserData(
      userInfo,
      avatarFile: avatarFile,
      cvFile: cvFile,
    );

    result.fold(
      (errorMessage) => emit(UserInfoError(errorMessage)),
      (_) async {
        await SharedPrefHelper.setData(
          AppConstants.isUserInfoCompletedKey,
          true,
        );
        emit(UserInfoSuccess());
      },
    );
  }
}
