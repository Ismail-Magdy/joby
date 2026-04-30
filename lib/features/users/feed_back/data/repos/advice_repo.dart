import "package:dartz/dartz.dart";

abstract class AdviceRepo {
  Future<Either<String, Unit>> sendFeedback(String message);
}
