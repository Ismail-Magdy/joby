import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:joby/core/helpers/constants.dart';
import 'package:path/path.dart' as p;

class EditProfileRepo {
  final SupabaseClient _supabaseClient;

  EditProfileRepo(this._supabaseClient);

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

      final fileExt = p.extension(file.path);
      final fileName =
          '$userId-${DateTime.now().millisecondsSinceEpoch}$fileExt';

      await _supabaseClient.storage
          .from(AppConstants.resumesBucket)
          .upload(
            fileName,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      final publicUrl = _supabaseClient.storage
          .from(AppConstants.resumesBucket)
          .getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      debugPrint('EditProfileRepo: Error uploading CV: $e');
      return null;
    }
  }

  /// Updates the user's contact/social info in the database.
  Future<bool> updateUserInfo({
    required String userId,
    required String whatsapp,
    String? linkedin,
    String? github,
    String? cvUrl,
  }) async {
    try {
      final dataToUpdate = {
        'whatsapp': whatsapp,
        if (linkedin != null && linkedin.isNotEmpty) 'linkedin': linkedin,
        if (github != null && github.isNotEmpty) 'github': github,
        'cv_url': ?cvUrl,
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
