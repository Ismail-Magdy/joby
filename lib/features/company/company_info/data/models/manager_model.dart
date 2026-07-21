class ManagerModel {
  final String id;
  final String? avatarUrl;

  ManagerModel({required this.id, this.avatarUrl});

  factory ManagerModel.fromJson(Map<String, dynamic> json) {
    return ManagerModel(
      id: json['id'] as String,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'avatar_url': avatarUrl};
  }
}
