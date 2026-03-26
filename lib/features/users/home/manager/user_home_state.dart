import '../../user_info/data/models/user_info_model.dart';

abstract class UserHomeState {}

class UserHomeInitial extends UserHomeState {}

class UserHomeLoading extends UserHomeState {}

class UserHomeSuccess extends UserHomeState {
  final UserInfoModel userInfo;

  UserHomeSuccess(this.userInfo);
}

class UserHomeError extends UserHomeState {
  final String message;

  UserHomeError(this.message);
}
