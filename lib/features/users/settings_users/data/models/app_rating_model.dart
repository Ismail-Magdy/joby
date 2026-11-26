class AppRatingModel {
  final int rating;
  final String? comment;
  final DateTime? updatedAt;

  const AppRatingModel({
    required this.rating,
    this.comment,
    this.updatedAt,
  });

  factory AppRatingModel.fromJson(Map<String, dynamic> json) {
    return AppRatingModel(
      rating: (json['rating'] as num?)?.toInt() ?? 5,
      comment: json['comment'] as String?,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }
}
