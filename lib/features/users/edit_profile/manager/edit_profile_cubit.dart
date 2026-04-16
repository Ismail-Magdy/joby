import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/repos/edit_profile_repo.dart';
import 'edit_profile_state.dart';

class EditProfileCubit extends Cubit<EditProfileState> {
  final EditProfileRepo editProfileRepo;
  final SupabaseClient supabaseClient;

  File? _pickedCvFile; // متغير بنحتفظ فيه بالملف اللي اليوزر اختاره

  EditProfileCubit(this.editProfileRepo, this.supabaseClient)
    : super(EditProfileInitial());

  // 1. دالة اختيار ملف الـ PDF
  Future<void> pickCv() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'], // مسموح بس بـ PDF
      );

      if (result != null && result.files.single.path != null) {
        _pickedCvFile = File(result.files.single.path!);
        final fileName = result.files.single.name;
        // بنبعت حالة إن الملف اتختار عشان الـ UI يتحدث
        emit(EditProfileCvPicked(file: _pickedCvFile!, fileName: fileName));
      }
    } catch (e) {
      emit(EditProfileError("Error picking file"));
    }
  }

  // 2. دالة حفظ التغييرات
  Future<void> saveChanges({
    required String whatsapp,
    required String linkedin,
    required String github,
  }) async {
    // التحقق من الرقم إجباري
    if (whatsapp.isEmpty) {
      emit(EditProfileError("WhatsApp number is required"));
      return;
    }

    emit(EditProfileLoading());

    try {
      final userId = supabaseClient.auth.currentUser!.id;
      String? finalCvUrl;

      // أ. لو اليوزر اختار CV جديد، نرفعه الأول
      if (_pickedCvFile != null) {
        finalCvUrl = await editProfileRepo.uploadCv(_pickedCvFile!);
        if (finalCvUrl == null) {
          emit(EditProfileError("Failed to upload CV."));
          return;
        }
      }

      // ب. نحدث البيانات في الداتا بيز (بما فيها لينك الـ CV الجديد لو وجد)
      final success = await editProfileRepo.updateUserInfo(
        userId: userId,
        whatsapp: whatsapp,
        linkedin: linkedin,
        github: github,
        cvUrl: finalCvUrl,
      );

      if (success) {
        emit(EditProfileSuccess());
      } else {
        emit(EditProfileError("Failed to update profile data."));
      }
    } catch (e) {
      emit(EditProfileError("An unexpected error occurred."));
    }
  }
}
