import "package:flutter_bloc/flutter_bloc.dart";
import "../data/repos/feed_back_repo.dart";
import "feed_back_state.dart";

class FeedBackCubit extends Cubit<FeedBackState> {
  final FeedBackRepo _feedBackRepo;

  FeedBackCubit({required FeedBackRepo feedBackRepo})
    : _feedBackRepo = feedBackRepo,
      super(FeedBackInitial());

  Future<void> sendFeedback(String message) async {
    emit(FeedBackSending());

    final result = await _feedBackRepo.sendFeedback(message);

    result.fold(
      (error) => emit(FeedBackError(error)),
      (_) => emit(FeedBackSent()),
    );
  }

  void reset() => emit(FeedBackInitial());
}
