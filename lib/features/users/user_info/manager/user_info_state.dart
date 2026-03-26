abstract class UserInfoState {}

class UserInfoInitial extends UserInfoState {}

class UserInfoLoading extends UserInfoState {}

class UserInfoSuccess extends UserInfoState {}

class UserInfoError extends UserInfoState {
  final String message;

  UserInfoError(this.message);
}
