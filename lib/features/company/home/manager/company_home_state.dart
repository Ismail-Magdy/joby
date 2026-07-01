import 'package:joby/features/users/user_info/data/models/user_info_model.dart';

abstract class CompanyHomeState {}

class CompanyHomeInitial extends CompanyHomeState {}

class CompanyHomeLoading extends CompanyHomeState {}

class CompanyHomeLoaded extends CompanyHomeState {
  final List<UserInfoModel> seekers;
  final Set<String> savedSeekerIds;
  final bool hasReachedMax;
  final bool isLoadingMore;

  CompanyHomeLoaded({
    required this.seekers,
    this.savedSeekerIds = const {},
    this.hasReachedMax = false,
    this.isLoadingMore = false,
  });

  CompanyHomeLoaded copyWith({
    List<UserInfoModel>? seekers,
    Set<String>? savedSeekerIds,
    bool? hasReachedMax,
    bool? isLoadingMore,
  }) {
    return CompanyHomeLoaded(
      seekers: seekers ?? this.seekers,
      savedSeekerIds: savedSeekerIds ?? this.savedSeekerIds,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class CompanyHomeError extends CompanyHomeState {
  final String message;
  CompanyHomeError(this.message);
}
