abstract class AdviceState {}

class AdviceInitial extends AdviceState {}

class AdviceSending extends AdviceState {}

class AdviceSent extends AdviceState {}

class AdviceError extends AdviceState {
  final String message;
  AdviceError(this.message);
}
