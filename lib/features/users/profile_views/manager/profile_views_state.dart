import 'package:joby/features/users/profile_views/data/models/profile_view_model.dart';

abstract class ProfileViewsState {}

class ProfileViewsInitial extends ProfileViewsState {}

class ProfileViewsLoading extends ProfileViewsState {}

class ProfileViewsEmpty extends ProfileViewsState {}

class ProfileViewsLoaded extends ProfileViewsState {
  final List<ProfileViewModel> views;
  ProfileViewsLoaded(this.views);
}

class ProfileViewsError extends ProfileViewsState {
  final String message;
  ProfileViewsError(this.message);
}
