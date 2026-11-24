import "dart:io";
import "package:dartz/dartz.dart";
import "../models/user_info_model.dart";

abstract class UserInfoRepo {
  Future<Either<String, void>> saveUserData(
    UserInfoModel userInfo, {
    File? avatarFile,
    File? cvFile,
  });

  Future<void> saveUserInfoDraft(Map<String, dynamic> draftData);

  Map<String, dynamic>? getUserInfoDraft();

  Future<void> clearUserInfoDraft();
}
