import 'package:joby/features/users/user_info/data/models/user_info_model.dart';

abstract class CompanyHomeState {}

class CompanyHomeInitial extends CompanyHomeState {}

class CompanyHomeLoading extends CompanyHomeState {}

class CompanyHomeLoaded extends CompanyHomeState {
  final List<UserInfoModel> seekers;
  final Set<String> savedSeekerIds; // For the local bookmark toggle state

  CompanyHomeLoaded({required this.seekers, this.savedSeekerIds = const {}});

  CompanyHomeLoaded copyWith({
    List<UserInfoModel>? seekers,
    Set<String>? savedSeekerIds,
  }) {
    return CompanyHomeLoaded(
      seekers: seekers ?? this.seekers,
      savedSeekerIds: savedSeekerIds ?? this.savedSeekerIds,
    );
  }
}

class CompanyHomeError extends CompanyHomeState {
  final String message;
  CompanyHomeError(this.message);
}
