import 'package:joby/core/helpers/location_helper.dart';

class UserInfoModel {
  final String? id;
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
    this.id,
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

  String get displayShortName {
    if (name.trim().isEmpty) return "";
    final parts = name.trim().split(" ");
    return parts.take(2).join(" ");
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) "id": id,
      "name": name,
      "job_category": jobCategory,
      "job_title": jobTitle,
      "level": level,
      "work_type": typeOfWork,
      "whatsapp": whatsapp,
      if (linkedin != null && linkedin!.isNotEmpty) "linkedin": linkedin,
      if (github != null && github!.isNotEmpty) "github": github,
      if (behance != null && behance!.isNotEmpty) "behance": behance,
      if (cvUrl != null) "cv_url": cvUrl,
      if (avatarUrl != null) "avatar_url": avatarUrl,
      "total_points": totalPoints,
      if (lastCheckIn != null) "last_check_in": lastCheckIn,
      "location_name": LocationHelper.normalizeLocationName(locationName),
      "latitude": latitude,
      "longitude": longitude,
    };
  }

  factory UserInfoModel.fromJson(Map<String, dynamic> json) {
    return UserInfoModel(
      id: json["id"]?.toString(),
      name: json["name"] ?? "",
      jobCategory: json["job_category"] ?? "",
      jobTitle: json["job_title"] ?? "",
      level: json["level"] ?? "",
      typeOfWork: json["work_type"] ?? "",
      whatsapp: json["whatsapp"] ?? "",
      linkedin: json["linkedin"],
      github: json["github"],
      behance: json["behance"],
      cvUrl: json["cv_url"],
      avatarUrl: json["avatar_url"],
      totalPoints: json["total_points"] ?? 0,
      lastCheckIn: json["last_check_in"],
      locationName: LocationHelper.normalizeLocationName(
        json["location_name"] ?? "",
      ),
      latitude: (json["latitude"] as num?)?.toDouble() ?? 0.0,
      longitude: (json["longitude"] as num?)?.toDouble() ?? 0.0,
    );
  }
}
