import "dart:async";
import "dart:io";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:joby/core/helpers/constants.dart";
import "package:joby/core/helpers/shared_prefrences_helper.dart";
import "../data/models/user_info_model.dart";
import "../data/repos/user_info_repo.dart";
import "user_info_state.dart";

class UserInfoCubit extends Cubit<UserInfoState> {
  final UserInfoRepo userInfoRepo;
  Timer? _draftSaveDebounce;

  UserInfoCubit({required this.userInfoRepo}) : super(UserInfoInitial());

  /// Loads any previously saved onboarding draft for the current user.
  Map<String, dynamic>? loadUserInfoDraft() {
    return userInfoRepo.getUserInfoDraft();
  }

  /// Debounces rapid text field updates before persisting the draft to disk.
  void scheduleDraftSave(Map<String, dynamic> Function() buildDraft) {
    _draftSaveDebounce?.cancel();
    _draftSaveDebounce = Timer(const Duration(milliseconds: 300), () async {
      await userInfoRepo.saveUserInfoDraft(buildDraft());
    });
  }

  /// Immediately persists the current onboarding draft (used for selections,
  /// file picks, step changes, and app lifecycle transitions).
  Future<void> saveUserInfoDraftNow(Map<String, dynamic> draftData) async {
    _draftSaveDebounce?.cancel();
    await userInfoRepo.saveUserInfoDraft(draftData);
  }

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
        _draftSaveDebounce?.cancel();
        await userInfoRepo.clearUserInfoDraft();
        await SharedPrefHelper.setData(
          AppConstants.isUserInfoCompletedKey,
          true,
        );
        emit(UserInfoSuccess());
      },
    );
  }

  @override
  Future<void> close() {
    _draftSaveDebounce?.cancel();
    return super.close();
  }
}
