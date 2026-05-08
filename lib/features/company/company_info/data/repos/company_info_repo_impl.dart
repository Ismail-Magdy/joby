import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

      // Use RPC to atomically upsert profiles + managers_data (bypasses RLS)
      await supabaseClient.rpc(
        'create_company_profile',
        params: {
          'p_name': name,
          'p_email': user.email ?? '',
          'p_avatar_url': avatarUrl,
        },
      );

      return const Right(null);
    } catch (e) {
      return Left("Error [${e.runtimeType}]: $e");
    }
  }
}
