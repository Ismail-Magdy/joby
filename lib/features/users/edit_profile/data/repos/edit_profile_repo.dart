import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:joby/core/helpers/constants.dart';

class EditProfileRepo {
  final SupabaseClient _supabaseClient;

  EditProfileRepo(this._supabaseClient);

  /// Uploads the avatar image to Supabase Storage and returns the public URL.
  Future<String?> uploadAvatar(File file) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        debugPrint(
          'EditProfileRepo: Cannot upload avatar — user not authenticated.',
        );
        return null;
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${userId}_$timestamp.jpg';

      final bytes = await file.readAsBytes();

      await _supabaseClient.storage
          .from("avatars")
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(
              cacheControl: "3600",
              upsert: true,
              contentType: "image/jpeg",
            ),
          );

      final publicUrl = _supabaseClient.storage
          .from("avatars")
          .getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      debugPrint('EditProfileRepo: Error uploading avatar: $e');
      return null;
    }
  }

  /// Uploads the CV file to Supabase Storage and returns the public URL.
  Future<String?> uploadCv(File file) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        debugPrint(
          'EditProfileRepo: Cannot upload CV — user not authenticated.',
        );
        return null;
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${userId}_$timestamp.pdf';

      final bytes = await file.readAsBytes();

      // Uses "cvs" bucket — same as user_info_repo_impl
      await _supabaseClient.storage
          .from("cvs")
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(
              cacheControl: "3600",
              upsert: true,
              contentType: "application/pdf",
            ),
          );

      final publicUrl = _supabaseClient.storage
          .from("cvs")
          .getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      debugPrint('EditProfileRepo: Error uploading CV: $e');
      return null;
    }
  }

  /// Updates the user's profile info in the database.
  Future<bool> updateUserInfo({
    required String userId,
    required String name,
    required String jobTitle,
    required String level,
    required String typeOfWork,
    required String whatsapp,
    String? linkedin,
    String? github,
    String? cvUrl,
    String? avatarUrl,
  }) async {
    try {
      final dataToUpdate = {
        'name': name,
        'job_title': jobTitle,
        'level': level,
        'type_of_work': typeOfWork,
        'whatsapp': whatsapp,
        if (linkedin != null && linkedin.isNotEmpty) 'linkedin': linkedin,
        if (github != null && github.isNotEmpty) 'github': github,
        if (cvUrl != null) 'cv_url': cvUrl,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      };

      await _supabaseClient
          .from(AppConstants.usersTable)
          .update(dataToUpdate)
          .eq('id', userId);

      return true;
    } catch (e) {
      debugPrint('EditProfileRepo: Error updating user info: $e');
      return false;
    }
  }
}
