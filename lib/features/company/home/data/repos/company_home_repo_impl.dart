import 'package:dartz/dartz.dart';
import 'package:joby/features/company/home/data/repos/company_home_repo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../users/user_info/data/models/user_info_model.dart';
import '../../../../../core/errors/error_handler.dart';

class CompanyHomeRepoImpl implements CompanyHomeRepo {
  final SupabaseClient supabaseClient;

  CompanyHomeRepoImpl({required this.supabaseClient});

  @override
  Future<Either<String, List<UserInfoModel>>> getSeekers({
    String? searchQuery,
    String? jobCategory,
    String? jobTitle,
    String? locationName,
    String? level,
  }) async {
    try {
      var query = supabaseClient.from('users').select();

      // Apply Search Filter (checking name or job_title)
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or(
          'name.ilike.%$searchQuery%,job_title.ilike.%$searchQuery%',
        );
      }

      // Apply Dropdown Filters
      if (jobCategory != null &&
          jobCategory.isNotEmpty &&
          jobCategory != 'All') {
        query = query.eq('job_category', jobCategory);
      }
      if (jobTitle != null && jobTitle.isNotEmpty && jobTitle != 'All') {
        query = query.eq('job_title', jobTitle);
      }
      if (locationName != null &&
          locationName.isNotEmpty &&
          locationName != 'All') {
        query = query.eq('location_name', locationName);
      }
      if (level != null && level.isNotEmpty && level != 'All') {
        query = query.eq('level', level);
      }

      // Gamification Logic: Order by total_points DESC
      final response = await query.order('total_points', ascending: false);

      final seekersList = (response as List)
          .map((json) => UserInfoModel.fromJson(json))
          .toList();

      return Right(seekersList);
    } catch (e) {
      return Left(ErrorHandler.handleError(e));
    }
  }
}
