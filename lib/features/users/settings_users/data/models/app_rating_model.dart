class AppRatingModel {
  final int rating;
  final String? comment;

  const AppRatingModel({required this.rating, this.comment});

  factory AppRatingModel.fromJson(Map<String, dynamic> json) {
    return AppRatingModel(
      rating: (json['rating'] as num?)?.toInt() ?? 5,
      comment: json['comment'] as String?,
    );
  }
}
