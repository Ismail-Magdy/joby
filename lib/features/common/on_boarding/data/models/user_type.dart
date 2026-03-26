enum UserType { seeker, company }

extension UserTypeExtension on UserType {
  String get value {
    switch (this) {
      case .seeker:
        return "seeker";
      case .company:
        return "company";
    }
  }
}
