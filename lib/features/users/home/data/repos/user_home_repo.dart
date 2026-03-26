import "package:dartz/dartz.dart";
import "../../../user_info/data/models/user_info_model.dart";

abstract class UserHomeRepo {
  Future<Either<String, UserInfoModel>> getUserProfile();
}
