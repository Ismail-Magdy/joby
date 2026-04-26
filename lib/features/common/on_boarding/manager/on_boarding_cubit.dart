import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/user_type.dart';
import '../data/repositories/user_type_repository.dart';
import 'on_boarding_state.dart';
import '../../../../core/errors/error_handler.dart';

class OnBoardingCubit extends Cubit<OnBoardingState> {
  final OnBoardingRepo onBoardingRepo;

  UserType? currentSelectedType;

  OnBoardingCubit({required this.onBoardingRepo}) : super(OnBoardingInitial());

  void selectUserType(UserType type) {
    currentSelectedType = type;
    emit(UserTypeSelected(type));
  }

  Future<void> saveSelection() async {
    if (currentSelectedType == null) {
      emit(const SaveUserTypeError("Please select an option first"));
      return;
    }

    emit(SaveUserTypeLoading());
    try {
      await onBoardingRepo.saveUserType(currentSelectedType!);
      emit(SaveUserTypeSuccess(currentSelectedType!));
    } catch (error) {
      emit(SaveUserTypeError(ErrorHandler.handleError(error)));
    }
  }
}
