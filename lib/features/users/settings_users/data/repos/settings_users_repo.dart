import 'package:dartz/dartz.dart';
import '../models/app_rating_model.dart';

abstract class SettingsUsersRepo {
  bool getCachedProfileVisibility();

  Future<Either<String, bool>> fetchProfileVisibility();

  Future<Either<String, void>> updateProfileVisibility(bool isVisible);

  bool getDailyNotificationsEnabled();

  Future<void> setDailyNotificationsEnabled(bool enabled);

  Future<Either<String, AppRatingModel?>> getUserRating();

  Future<Either<String, void>> submitAppRating({
    required int rating,
    String? comment,
  });
}
