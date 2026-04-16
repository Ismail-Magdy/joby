import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p; // بنحتاجها عشان نجيب امتداد الملف

class EditProfileRepo {
  final SupabaseClient _supabaseClient;

  EditProfileRepo(this._supabaseClient);

  // 1. دالة رفع الـ CV لـ Supabase Storage
  Future<String?> uploadCv(File file) async {
    try {
      final userId = _supabaseClient.auth.currentUser!.id;
      final fileExt = p.extension(file.path); // بجيب الامتداد (.pdf)
      // بنعمل اسم مميز للملف عبارة عن ID اليوزر + الوقت
      final fileName =
          '$userId-${DateTime.now().millisecondsSinceEpoch}$fileExt';

      // بنرفع الملف لباكت اسمها 'resumes' (اتأكد إنك عملتها في Supabase)
      await _supabaseClient.storage
          .from('resumes')
          .upload(
            fileName,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      // بنجيب لينك الملف العام (Public URL)
      final publicUrl = _supabaseClient.storage
          .from('resumes')
          .getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      // TODO: Log error properly
      print("Error uploading CV: $e");
      return null;
    }
  }

  // 2. دالة تحديث بيانات اليوزر ف الداتا بيز
  Future<bool> updateUserInfo({
    required String userId,
    required String whatsapp,
    String? linkedin,
    String? github,
    String? cvUrl,
  }) async {
    try {
      // بنعمل Map بالداتا الجديدة (بنحدث بس الحقول اللي جت)
      final dataToUpdate = {
        'whatsapp': whatsapp,
        if (linkedin != null) 'linkedin': linkedin,
        if (github != null) 'github': github,
        if (cvUrl != null) 'cv_url': cvUrl,
      };

      await _supabaseClient
          .from('user_info')
          .update(dataToUpdate)
          .eq('id', userId); // بنحدث بناءً على الـ User ID

      return true;
    } catch (e) {
      print("Error updating user info: $e");
      return false;
    }
  }
}
