import "dart:io";
import "dart:typed_data";
import "package:dartz/dartz.dart";
import "package:image_picker/image_picker.dart";
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
        return const Left("User is Not Authenticated");
      }

      String? finalAvatarUrl = userInfo.avatarUrl;
      String? finalCvUrl = userInfo.cvUrl;

      if (avatarFile != null) {
        String avatarPath = avatarFile.path;
        if (avatarPath.startsWith("file://")) {
          try {
            avatarPath = Uri.parse(avatarPath).toFilePath();
          } catch (_) {
            avatarPath = avatarPath.replaceFirst("file://", "");
          }
        }
        final normalizedAvatarFile = File(avatarPath);

        Uint8List? avatarBytes;
        if (await normalizedAvatarFile.exists()) {
          try {
            avatarBytes = await normalizedAvatarFile.readAsBytes();
          } catch (_) {}
        }

        if (avatarBytes == null || avatarBytes.isEmpty) {
          try {
            avatarBytes = await XFile(avatarFile.path).readAsBytes();
          } catch (_) {
            try {
              avatarBytes = await normalizedAvatarFile.readAsBytes();
            } catch (_) {}
          }
        }

        if (avatarBytes != null && avatarBytes.isNotEmpty) {
          final String avatarName = "$userId.jpg";
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
        } else if (finalAvatarUrl == null || finalAvatarUrl.isEmpty) {
          return const Left("Profile Picture File does not Exist");
        }
      }

      if (cvFile != null) {
        String cvPath = cvFile.path;
        if (cvPath.startsWith("file://")) {
          try {
            cvPath = Uri.parse(cvPath).toFilePath();
          } catch (_) {
            cvPath = cvPath.replaceFirst("file://", "");
          }
        }
        final normalizedCvFile = File(cvPath);

        Uint8List? cvBytes;
        if (await normalizedCvFile.exists()) {
          try {
            cvBytes = await normalizedCvFile.readAsBytes();
          } catch (_) {}
        }

        if (cvBytes == null || cvBytes.isEmpty) {
          try {
            cvBytes = await XFile(cvFile.path).readAsBytes();
          } catch (_) {
            try {
              cvBytes = await normalizedCvFile.readAsBytes();
            } catch (_) {}
          }
        }

        if (cvBytes != null && cvBytes.isNotEmpty) {
          final String cvName = "$userId.pdf";
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
        } else if (finalCvUrl == null || finalCvUrl.isEmpty) {
          return const Left("CV File does not Exist");
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
    } catch (error) {
      return Left(ErrorHandler.handleError(error));
    }
  }
}
