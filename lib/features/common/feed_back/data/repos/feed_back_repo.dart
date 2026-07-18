import "package:dartz/dartz.dart";

abstract class FeedBackRepo {
  Future<Either<String, Unit>> sendFeedback(String message);
}
