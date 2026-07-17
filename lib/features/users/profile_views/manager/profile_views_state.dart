import 'package:joby/features/users/profile_views/data/models/profile_view_model.dart';

abstract class ProfileViewsState {}

class ProfileViewsInitial extends ProfileViewsState {}

class ProfileViewsLoading extends ProfileViewsState {}

class ProfileViewsEmpty extends ProfileViewsState {}

class ProfileViewsLoaded extends ProfileViewsState {
  final List<ProfileViewModel> views;
  final int totalViews;
  final bool isTrendUp;
  final int trendDifference;

  ProfileViewsLoaded({
    required this.views,
    required this.totalViews,
    required this.isTrendUp,
    required this.trendDifference,
  });
}

class ProfileViewsError extends ProfileViewsState {
  final String message;
  ProfileViewsError(this.message);
}
