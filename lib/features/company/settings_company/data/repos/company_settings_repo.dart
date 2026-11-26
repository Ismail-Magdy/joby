import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:joby/features/users/settings_users/data/models/app_rating_model.dart';
import '../models/company_settings_profile.dart';

abstract class CompanySettingsRepo {
  CompanySettingsProfile? getCachedCompanyProfile();

  Future<Either<String, CompanySettingsProfile>> fetchCompanyProfile();

  Future<Either<String, CompanySettingsProfile>> updateCompanyProfile({
    required String name,
    File? newAvatarFile,
    String? existingAvatarUrl,
  });

  Future<Either<String, AppRatingModel?>> getUserRating();

  Future<Either<String, void>> submitAppRating({
    required int rating,
    String? comment,
  });
}
