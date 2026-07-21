import 'package:dartz/dartz.dart';
import 'package:joby/features/company/home/data/repos/company_home_repo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../users/user_info/data/models/user_info_model.dart';
import '../../../../../core/errors/error_handler.dart';

class CompanyHomeRepoImpl implements CompanyHomeRepo {
  final SupabaseClient supabaseClient;
  final SharedPreferences sharedPreferences;

  static const int pageSize = 10;

  CompanyHomeRepoImpl({
    required this.supabaseClient,
    required this.sharedPreferences,
  });

  @override
  Future<Either<String, List<UserInfoModel>>> getSeekers({
    String? searchQuery,
    String? jobCategory,
    String? jobTitle,
    String? locationName,
    String? level,
    required int page,
  }) async {
    try {
      var query = supabaseClient.from('seekers').select();

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or(
          'name.ilike.%$searchQuery%,job_title.ilike.%$searchQuery%,job_category.ilike.%$searchQuery%',
        );
      }

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
        query = query.ilike('location_name', '%$locationName%');
      }

      if (level != null && level.isNotEmpty && level != 'All') {
        query = query.eq('level', level);
      }

      // Pagination range: page 0 => rows 0-9, page 1 => rows 10-19, ...
      final from = page * pageSize;
      final to = from + pageSize - 1;

      final response = await query
          .order('total_points', ascending: false)
          .range(from, to);

      final dataList = List<Map<String, dynamic>>.from(response as List);
      final seekersList = dataList
          .map((json) => UserInfoModel.fromJson(json))
          .toList();

      return Right(seekersList);
    } catch (e) {
      return Left(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<String, Set<String>>> getSavedSeekerIds() async {
    try {
      final List<String>? savedList = sharedPreferences.getStringList(
        'saved_seeker_ids',
      );
      if (savedList != null) {
        return Right(savedList.toSet());
      }
      return const Right({});
    } catch (e) {
      return Left(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<String, List<UserInfoModel>>> getSeekersByIds(
    Set<String> ids,
  ) async {
    try {
      if (ids.isEmpty) return const Right([]);

      final response = await supabaseClient
          .from('seekers')
          .select()
          .inFilter('id', ids.toList())
          .order('total_points', ascending: false);

      final dataList = List<Map<String, dynamic>>.from(response as List);
      final seekers = dataList
          .map((json) => UserInfoModel.fromJson(json))
          .toList();
      return Right(seekers);
    } catch (e) {
      return Left(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<String, void>> saveSeekerIds(Set<String> savedIds) async {
    try {
      await sharedPreferences.setStringList(
        'saved_seeker_ids',
        savedIds.toList(),
      );
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handleError(e));
    }
  }
}
