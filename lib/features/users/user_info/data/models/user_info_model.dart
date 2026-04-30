class UserInfoModel {
  final String name;
  final String jobCategory;
  final String jobTitle;
  final String level;
  final String typeOfWork;
  final String whatsapp;
  final String? linkedin;
  final String? github;
  final String? behance;
  final String? cvUrl;
  final String? avatarUrl;
  final int totalPoints;
  final String? lastCheckIn;
  final String locationName;
  final double latitude;
  final double longitude;

  UserInfoModel({
    required this.name,
    required this.jobCategory,
    required this.jobTitle,
    required this.level,
    required this.typeOfWork,
    required this.whatsapp,
    this.linkedin,
    this.github,
    this.behance,
    this.cvUrl,
    this.avatarUrl,
    this.totalPoints = 0,
    this.lastCheckIn,
    required this.locationName,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "job_category": jobCategory,
      "job_title": jobTitle,
      "level": level,
      "type_of_work": typeOfWork,
      "whatsapp": whatsapp,
      if (linkedin != null && linkedin!.isNotEmpty) "linkedin": linkedin,
      if (github != null && github!.isNotEmpty) "github": github,
      if (behance != null && behance!.isNotEmpty) "behance": behance,
      if (cvUrl != null) "cv_url": cvUrl,
      if (avatarUrl != null) "avatar_url": avatarUrl,
      "total_points": totalPoints,
      if (lastCheckIn != null) "last_check_in": lastCheckIn,
      "location_name": locationName,
      "latitude": latitude,
      "longitude": longitude,
    };
  }

  factory UserInfoModel.fromJson(Map<String, dynamic> json) {
    return UserInfoModel(
      name: json["name"] ?? "",
      jobCategory: json["job_category"] ?? "",
      jobTitle: json["job_title"] ?? "",
      level: json["level"] ?? "",
      typeOfWork: json["type_of_work"] ?? "",
      whatsapp: json["whatsapp"] ?? "",
      linkedin: json["linkedin"],
      github: json["github"],
      behance: json["behance"],
      cvUrl: json["cv_url"],
      avatarUrl: json["avatar_url"],
      totalPoints: json["total_points"] ?? 0,
      lastCheckIn: json["last_check_in"],
      locationName: json["location_name"] ?? "",
      latitude: (json["latitude"] as num?)?.toDouble() ?? 0.0,
      longitude: (json["longitude"] as num?)?.toDouble() ?? 0.0,
    );
  }
}
