import 'package:dartz/dartz.dart';
import 'package:joby/core/errors/error_handler.dart';
import 'package:joby/core/helpers/constants.dart';
import 'package:joby/features/users/notification/services/local_notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_rating_model.dart';
import 'settings_users_repo.dart';

class SettingsUsersRepoImpl implements SettingsUsersRepo {
  final SupabaseClient supabaseClient;
  final SharedPreferences sharedPrefs;

  SettingsUsersRepoImpl({
    required this.supabaseClient,
    required this.sharedPrefs,
  });

  String get _visibilityCacheKey {
    final userId = supabaseClient.auth.currentUser?.id ?? 'guest';
    return 'settings_profile_visibility_$userId';
  }

  @override
  bool getCachedProfileVisibility() {
    return sharedPrefs.getBool(_visibilityCacheKey) ?? true;
  }

  @override
  Future<Either<String, bool>> fetchProfileVisibility() async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) return const Left('User is not authenticated');

      final data = await supabaseClient
          .from(AppConstants.usersTable)
          .select('is_visible')
          .eq('id', userId)
          .maybeSingle();

      final isVisible = (data?['is_visible'] as bool?) ?? true;
      await sharedPrefs.setBool(_visibilityCacheKey, isVisible);
      return Right(isVisible);
    } catch (error) {
      return Left(ErrorHandler.handleError(error));
    }
  }

  @override
  Future<Either<String, void>> updateProfileVisibility(bool isVisible) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) return const Left('User is not authenticated');

      await supabaseClient
          .from(AppConstants.usersTable)
          .update({'is_visible': isVisible})
          .eq('id', userId);

      await sharedPrefs.setBool(_visibilityCacheKey, isVisible);
      return const Right(null);
    } catch (error) {
      return Left(ErrorHandler.handleError(error));
    }
  }

  @override
  bool getDailyNotificationsEnabled() {
    return sharedPrefs.getBool(
          LocalNotificationService.dailyNotificationsEnabledKey,
        ) ??
        true;
  }

  @override
  Future<void> setDailyNotificationsEnabled(bool enabled) async {
    await sharedPrefs.setBool(
      LocalNotificationService.dailyNotificationsEnabledKey,
      enabled,
    );
  }

  @override
  Future<Either<String, AppRatingModel?>> getUserRating() async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) return const Left('User is not authenticated');

      final data = await supabaseClient
          .from('app_ratings')
          .select('rating, comment')
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

      final trimmedComment = comment?.trim();
      await supabaseClient.from('app_ratings').upsert({
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
}
