import "dart:io";
import "package:dartz/dartz.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import "../models/user_info_model.dart";
import "user_info_repo.dart";
import "../../../../../core/errors/error_handler.dart";

class UserInfoRepoImpl implements UserInfoRepo {
  final SupabaseClient supabaseClient;

  UserInfoRepoImpl({required this.supabaseClient});

  @override
  Future<Either<String, void>> saveUserData(
    UserInfoModel userInfo, {
    File? avatarFile,
    File? cvFile,
  }) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;

      if (userId == null) {
        return const Left("User is not authenticated.");
      }

      String? finalAvatarUrl = userInfo.avatarUrl;
      String? finalCvUrl = userInfo.cvUrl;
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      if (avatarFile != null) {
        final String avatarName = "${userId}_$timestamp.jpg";

        final avatarBytes = await avatarFile.readAsBytes();

        await supabaseClient.storage
            .from("avatars")
            .uploadBinary(
              avatarName,
              avatarBytes,
              fileOptions: const FileOptions(
                cacheControl: "3600",
                upsert: true,
                contentType: "image/jpeg",
              ),
            );
        finalAvatarUrl = supabaseClient.storage
            .from("avatars")
            .getPublicUrl(avatarName);
      }

      if (cvFile != null) {
        final String cvName = "${userId}_$timestamp.pdf";

        final cvBytes = await cvFile.readAsBytes();

        await supabaseClient.storage
            .from("cvs")
            .uploadBinary(
              cvName,
              cvBytes,
              fileOptions: const FileOptions(
                cacheControl: "3600",
                upsert: true,
                contentType: "application/pdf",
              ),
            );
        finalCvUrl = supabaseClient.storage.from("cvs").getPublicUrl(cvName);
      }

      final updatedUserInfo = UserInfoModel(
        name: userInfo.name,
        jobCategory: userInfo.jobCategory,
        jobTitle: userInfo.jobTitle,
        level: userInfo.level,
        typeOfWork: userInfo.typeOfWork,
        whatsapp: userInfo.whatsapp,
        linkedin: userInfo.linkedin,
        github: userInfo.github,
        cvUrl: finalCvUrl,
        avatarUrl: finalAvatarUrl,
      );

      await supabaseClient.from("users").upsert({
        "id": userId,
        ...updatedUserInfo.toMap(),
      });

      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handleError(e));
    }
  }
}
