import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/errors/error_handler.dart';
import 'company_info_repo.dart';

class CompanyInfoRepoImpl implements CompanyInfoRepo {
  final SupabaseClient supabaseClient;

  CompanyInfoRepoImpl({required this.supabaseClient});

  @override
  Future<Either<String, void>> completeCompanyInfo({
    required String name,
    String? profileImageUrl,
    File? profileImageFile,
  }) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        return const Left("User is not authenticated");
      }

      String? avatarUrl = profileImageUrl;

      if (profileImageFile != null) {
        final fileName =
            '${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        await supabaseClient.storage
            .from('avatars')
            .upload(fileName, profileImageFile);

        avatarUrl = supabaseClient.storage
            .from('avatars')
            .getPublicUrl(fileName);
      } else if (avatarUrl == null || avatarUrl.isEmpty) {
        avatarUrl = null;
      }

      // Update name in profiles table
      await supabaseClient.from('profiles').update({
        'name': name,
      }).eq('id', user.id);

      // Upsert avatar_url in managers_data table
      await supabaseClient.from('managers_data').upsert({
        'id': user.id,
        'avatar_url': avatarUrl,
      });

      return const Right(null);
    } catch (e) {
      if (e is PostgrestException) {
        return Left("Database Error: ${e.message}");
      }
      return Left(ErrorHandler.handleError(e));
    }
  }
}
