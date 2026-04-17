import "package:flutter_bloc/flutter_bloc.dart";
import "../data/repos/advice_repo.dart";
import "advice_state.dart";

class AdviceCubit extends Cubit<AdviceState> {
  final AdviceRepo _adviceRepo;

  AdviceCubit({required AdviceRepo adviceRepo})
    : _adviceRepo = adviceRepo,
      super(AdviceInitial());

  Future<void> sendFeedback(String message) async {
    emit(AdviceSending());

    final result = await _adviceRepo.sendFeedback(message);

    result.fold((error) => emit(AdviceError(error)), (_) => emit(AdviceSent()));
  }

  void reset() => emit(AdviceInitial());
}
