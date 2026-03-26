import 'package:equatable/equatable.dart';
import '../data/models/user_type.dart';

abstract class OnBoardingState extends Equatable {
  const OnBoardingState();

  @override
  List<Object?> get props => [];
}

class OnBoardingInitial extends OnBoardingState {}

class UserTypeSelected extends OnBoardingState {
  final UserType selectedType;

  const UserTypeSelected(this.selectedType);

  @override
  List<Object?> get props => [selectedType];
}

class SaveUserTypeLoading extends OnBoardingState {}

class SaveUserTypeSuccess extends OnBoardingState {
  final UserType savedType;

  const SaveUserTypeSuccess(this.savedType);

  @override
  List<Object?> get props => [savedType];
}

class SaveUserTypeError extends OnBoardingState {
  final String message;

  const SaveUserTypeError(this.message);

  @override
  List<Object?> get props => [message];
}
