import 'package:joby/features/users/user_info/data/models/user_info_model.dart';

abstract class AiChatRepo {
  Future<UserInfoModel?> getUserProfile();
}
