import 'package:equatable/equatable.dart';

abstract class CompanyInfoState extends Equatable {
  const CompanyInfoState();

  @override
  List<Object?> get props => [];
}

class CompanyInfoInitial extends CompanyInfoState {}

class CompanyInfoLoading extends CompanyInfoState {}

class CompanyInfoSuccess extends CompanyInfoState {}

class CompanyInfoError extends CompanyInfoState {
  final String message;

  const CompanyInfoError(this.message);

  @override
  List<Object?> get props => [message];
}

class CompanyInfoAvatarPicked extends CompanyInfoState {
  final String path;

  const CompanyInfoAvatarPicked(this.path);

  @override
  List<Object?> get props => [path];
}
