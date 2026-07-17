import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfileRepo {
  final SupabaseClient _supabaseClient;

  EditProfileRepo(this._supabaseClient);

  /// Uploads the avatar image to Supabase Storage and returns the public URL.
  Future<String?> uploadAvatar(File file) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        debugPrint(
          'EditProfileRepo: Cannot upload avatar — user not authenticated',
        );
        return null;
      }

      final fileName = '$userId.jpg';
      final bytes = await file.readAsBytes();

      await _supabaseClient.storage
          .from("avatars")
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(
              cacheControl: "0",
              upsert: true,
              contentType: "image/jpeg",
            ),
          );

      return _supabaseClient.storage.from("avatars").getPublicUrl(fileName);
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

      // CV
      final fileName = '$userId.pdf';
      final bytes = await file.readAsBytes();

      await _supabaseClient.storage
          .from("cvs")
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(
              cacheControl: "0",
              upsert: true,
              contentType: "application/pdf",
            ),
          );

      return _supabaseClient.storage.from("cvs").getPublicUrl(fileName);
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
    String? behance,
    String? cvUrl,
    String? avatarUrl,
  }) async {
    try {
      final dataToUpdate = <String, dynamic>{
        if (name.isNotEmpty) 'name': name,
        if (jobTitle.isNotEmpty) 'job_title': jobTitle,
        if (level.isNotEmpty) 'level': level,
        if (typeOfWork.isNotEmpty) 'work_type': typeOfWork,
        if (whatsapp.isNotEmpty) 'whatsapp': whatsapp,
        if (linkedin != null && linkedin.isNotEmpty) 'linkedin': linkedin,
        if (github != null && github.isNotEmpty) 'github': github,
        if (behance != null && behance.isNotEmpty) 'behance': behance,
        if (cvUrl != null) 'cv_url': cvUrl,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      };

      if (dataToUpdate.isEmpty) return true;

      await _supabaseClient
          .from("seekers")
          .update(dataToUpdate)
          .eq('id', userId);

      return true;
    } catch (e) {
      debugPrint('EditProfileRepo: Error updating user info: $e');
      return false;
    }
  }
}
