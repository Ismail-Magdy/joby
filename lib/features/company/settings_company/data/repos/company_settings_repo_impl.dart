import 'dart:io';
import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:joby/core/errors/error_handler.dart';
import 'package:joby/core/helpers/constants.dart';
import 'package:joby/features/users/settings_users/data/models/app_rating_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/company_settings_profile.dart';
import 'company_settings_repo.dart';

class CompanySettingsRepoImpl implements CompanySettingsRepo {
  final SupabaseClient supabaseClient;
  final SharedPreferences sharedPrefs;

  CompanySettingsRepoImpl({
    required this.supabaseClient,
    required this.sharedPrefs,
  });

  String get _nameCacheKey {
    final userId = supabaseClient.auth.currentUser?.id ?? 'guest';
    return 'company_settings_name_$userId';
  }

  String get _avatarCacheKey {
    final userId = supabaseClient.auth.currentUser?.id ?? 'guest';
    return 'company_settings_avatar_$userId';
  }

  @override
  CompanySettingsProfile? getCachedCompanyProfile() {
    final cachedName = sharedPrefs.getString(_nameCacheKey);
    final cachedAvatar = sharedPrefs.getString(_avatarCacheKey);
    if (cachedName == null && cachedAvatar == null) return null;
    return CompanySettingsProfile(
      name: cachedName ?? '',
      avatarUrl: cachedAvatar,
    );
  }

  @override
  Future<Either<String, CompanySettingsProfile>> fetchCompanyProfile() async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) return const Left('User is not authenticated');

      final data = await supabaseClient
          .from(AppConstants.companiesTable)
          .select('name, avatar_url')
          .eq('id', userId)
          .maybeSingle();

      final profile = CompanySettingsProfile(
        name: (data?['name'] as String?) ?? '',
        avatarUrl: data?['avatar_url'] as String?,
      );

      await _cacheProfile(profile);
      return Right(profile);
    } catch (error) {
      return Left(ErrorHandler.handleError(error));
    }
  }

  @override
  Future<Either<String, CompanySettingsProfile>> updateCompanyProfile({
    required String name,
    File? newAvatarFile,
    String? existingAvatarUrl,
  }) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) return const Left('User is not authenticated');

      final trimmedName = name.trim();
      String? finalAvatarUrl = existingAvatarUrl;

      if (newAvatarFile != null) {
        String avatarPath = newAvatarFile.path;
        if (avatarPath.startsWith('file://')) {
          try {
            avatarPath = Uri.parse(avatarPath).toFilePath();
          } catch (_) {
            avatarPath = avatarPath.replaceFirst('file://', '');
          }
        }
        final normalizedFile = File(avatarPath);

        Uint8List? avatarBytes;
        if (await normalizedFile.exists()) {
          try {
            avatarBytes = await normalizedFile.readAsBytes();
          } catch (_) {}
        }
        if (avatarBytes == null || avatarBytes.isEmpty) {
          try {
            avatarBytes = await XFile(newAvatarFile.path).readAsBytes();
          } catch (_) {}
        }

        if (avatarBytes == null || avatarBytes.isEmpty) {
          return const Left('Selected image file could not be read');
        }

        final fileName =
            '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        await supabaseClient.storage
            .from('avatars')
            .uploadBinary(
              fileName,
              avatarBytes,
              fileOptions: const FileOptions(
                cacheControl: '0',
                upsert: true,
                contentType: 'image/jpeg',
              ),
            );

        finalAvatarUrl = supabaseClient.storage
            .from('avatars')
            .getPublicUrl(fileName);
      }

      await supabaseClient
          .from(AppConstants.companiesTable)
          .update({'name': trimmedName, 'avatar_url': finalAvatarUrl})
          .eq('id', userId);

      final updated = CompanySettingsProfile(
        name: trimmedName,
        avatarUrl: finalAvatarUrl,
      );
      await _cacheProfile(updated);
      return Right(updated);
    } catch (error) {
      return Left(ErrorHandler.handleError(error));
    }
  }

  @override
  Future<Either<String, AppRatingModel?>> getUserRating() async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) return const Left('User is not authenticated');

      final data = await supabaseClient
          .from('app_ratings')
          .select('rating, comment, updated_at')
          .eq('user_id', userId)
          .maybeSingle();

      if (data == null) return const Right(null);
      return Right(AppRatingModel.fromJson(data));
    } catch (error) {
      return Left(ErrorHandler.handleError(error));
    }
  }

  @override
  Future<Either<String, void>> submitAppRating({
    required int rating,
    String? comment,
  }) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) return const Left('User is not authenticated');

      final existing = await supabaseClient
          .from('app_ratings')
          .select('user_id')
          .eq('user_id', userId)
          .maybeSingle();

      if (existing != null) {
        return const Left('You have already submitted your rating');
      }

      final trimmedComment = comment?.trim();
      await supabaseClient.from('app_ratings').insert({
        'user_id': userId,
        'rating': rating,
        'comment': (trimmedComment == null || trimmedComment.isEmpty)
            ? null
            : trimmedComment,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });

      return const Right(null);
    } catch (error) {
      return Left(ErrorHandler.handleError(error));
    }
  }

  Future<void> _cacheProfile(CompanySettingsProfile profile) async {
    await sharedPrefs.setString(_nameCacheKey, profile.name);
    if (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty) {
      await sharedPrefs.setString(_avatarCacheKey, profile.avatarUrl!);
    } else {
      await sharedPrefs.remove(_avatarCacheKey);
    }
  }
}
