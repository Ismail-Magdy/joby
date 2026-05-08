import 'package:dartz/dartz.dart';
import '../../../../users/user_info/data/models/user_info_model.dart';

abstract class CompanyHomeRepo {
  Future<Either<String, List<UserInfoModel>>> getSeekers({
    String? searchQuery,
    String? jobCategory,
    String? jobTitle,
    String? locationName,
    String? level,
  });
}
