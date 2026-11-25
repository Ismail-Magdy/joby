abstract class PointsState {}

class PointsInitial extends PointsState {}

class PointsLoading extends PointsState {}

class PointsClaimCelebration extends PointsState {
  final int pointsGained;
  PointsClaimCelebration(this.pointsGained);
}

class PointsClaimAlreadyClaimed extends PointsState {}

class PointsClaimError extends PointsState {
  final String message;

  PointsClaimError(this.message);
}

class PointsTotalUpdated extends PointsState {
  final int totalPoints;

  PointsTotalUpdated(this.totalPoints);
}
