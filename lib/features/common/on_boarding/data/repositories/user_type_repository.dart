import 'package:shared_preferences/shared_preferences.dart';
import 'package:joby/core/helpers/constants.dart';
import '../models/user_type.dart';

abstract class OnBoardingRepo {
  Future<void> saveUserType(UserType type);
  Future<UserType?> getUserType();
}

class OnBoardingRepoImpl implements OnBoardingRepo {
  final SharedPreferences sharedPreferences;
  static const String _userTypeKey = AppConstants.userTypeKey;

  OnBoardingRepoImpl({required this.sharedPreferences});

  @override
  Future<void> saveUserType(UserType type) async {
    await sharedPreferences.setString(_userTypeKey, type.value);
  }

  @override
  Future<UserType?> getUserType() async {
    final String? typeString = sharedPreferences.getString(_userTypeKey);

    if (typeString == UserType.company.value) {
      return .company;
    } else if (typeString == UserType.seeker.value) {
      return .seeker;
    }
    return null;
  }
}
