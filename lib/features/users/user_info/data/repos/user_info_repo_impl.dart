import "dart:io";
import "package:dartz/dartz.dart";
import "package:flutter/foundation.dart";
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
      final userEmail = supabaseClient.auth.currentUser?.email ?? '';

      if (userId == null) {
        return const Left("User is not authenticated.");
      }

      String? finalAvatarUrl = userInfo.avatarUrl;
      String? finalCvUrl = userInfo.cvUrl;

      if (avatarFile != null) {
        if (await avatarFile.exists()) {
          //
          final String avatarName = "$userId.jpg";
          final avatarBytes = await avatarFile.readAsBytes();

          await supabaseClient.storage
              .from("avatars")
              .uploadBinary(
                avatarName,
                avatarBytes,
                fileOptions: const FileOptions(
                  cacheControl: "0",
                  upsert: true,
                  contentType: "image/jpeg",
                ),
              );
          finalAvatarUrl = supabaseClient.storage
              .from("avatars")
              .getPublicUrl(avatarName);
        } else {
          return const Left(
            "Profile picture file does not exist. Please select it again",
          );
        }
      }

      if (cvFile != null) {
        if (await cvFile.exists()) {
          //
          final String cvName = "$userId.pdf";
          final cvBytes = await cvFile.readAsBytes();

          await supabaseClient.storage
              .from("cvs")
              .uploadBinary(
                cvName,
                cvBytes,
                fileOptions: const FileOptions(
                  cacheControl: "0",
                  upsert: true,
                  contentType: "application/pdf",
                ),
              );
          finalCvUrl = supabaseClient.storage.from("cvs").getPublicUrl(cvName);
        } else {
          return const Left(
            "Curriculum vitae file does not exist. Please select it again.",
          );
        }
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
        behance: userInfo.behance,
        cvUrl: finalCvUrl,
        avatarUrl: finalAvatarUrl,
        locationName: userInfo.locationName,
        latitude: userInfo.latitude,
        longitude: userInfo.longitude,
      );

      await supabaseClient.from("seekers").upsert({
        "id": userId,
        "email": userEmail,
        ...updatedUserInfo.toMap(),
      });

      return const Right(null);
    } catch (e) {
      debugPrint("🚨 CRITICAL SaveUserData Error: $e");
      return Left(ErrorHandler.handleError(e));
    }
  }
}
