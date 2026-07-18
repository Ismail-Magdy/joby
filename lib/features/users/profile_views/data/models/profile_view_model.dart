class ProfileViewModel {
  final String companyId;
  final String companyName;
  final String? companyAvatar;
  final DateTime viewedAt;

  ProfileViewModel({
    required this.companyId,
    required this.companyName,
    this.companyAvatar,
    required this.viewedAt,
  });

  factory ProfileViewModel.fromJson(Map<String, dynamic> json) {
    final companyData = json["companies"] as Map<String, dynamic>? ?? {};

    return ProfileViewModel(
      companyId: companyData["id"] ?? "",
      companyName: companyData["name"] ?? "Unknown Company",
      companyAvatar: companyData["avatar_url"],
      viewedAt: DateTime.parse(json["viewed_at"]).toLocal(),
    );
  }
}
