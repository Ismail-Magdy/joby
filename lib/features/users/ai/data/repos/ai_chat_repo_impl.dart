import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:joby/features/users/user_info/data/models/user_info_model.dart';
import 'ai_chat_repo.dart';

class AiChatRepoImpl implements AiChatRepo {
  final SupabaseClient supabaseClient;

  AiChatRepoImpl({required this.supabaseClient});

  @override
  Future<UserInfoModel?> getUserProfile() async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) return null;

      final data = await supabaseClient
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      return UserInfoModel.fromJson(data);
    } catch (_) {
      // Graceful failure — AI will work without personalization
      return null;
    }
  }
}
