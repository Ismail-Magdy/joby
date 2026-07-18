abstract class FeedBackState {}

class FeedBackInitial extends FeedBackState {}

class FeedBackSending extends FeedBackState {}

class FeedBackSent extends FeedBackState {}

class FeedBackError extends FeedBackState {
  final String message;
  FeedBackError(this.message);
}
