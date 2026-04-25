import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/repos/edit_profile_repo.dart';
import 'edit_profile_state.dart';

class EditProfileCubit extends Cubit<EditProfileState> {
  final EditProfileRepo editProfileRepo;
  final SupabaseClient supabaseClient;

  File? _pickedCvFile;
  File? _pickedAvatarFile;

  EditProfileCubit(this.editProfileRepo, this.supabaseClient)
    : super(EditProfileInitial());

  /// Pick an avatar image from the gallery.
  Future<void> pickAvatar() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        _pickedAvatarFile = File(image.path);
        emit(EditProfileAvatarPicked(file: _pickedAvatarFile!));
      }
    } catch (e) {
      emit(EditProfileError("Error picking image"));
    }
  }

  /// Pick a PDF file from the device.
  Future<void> pickCv() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        _pickedCvFile = File(result.files.single.path!);
        final fileName = result.files.single.name;
        emit(EditProfileCvPicked(file: _pickedCvFile!, fileName: fileName));
      }
    } catch (e) {
      emit(EditProfileError("Error picking file"));
    }
  }

  /// Save all profile changes to Supabase.
  Future<void> saveChanges({
    required String name,
    required String jobTitle,
    required String level,
    required String typeOfWork,
    required String whatsapp,
    required String linkedin,
    required String github,
  }) async {
    // Validation
    if (name.trim().isEmpty) {
      emit(EditProfileError("Name is required"));
      return;
    }

    if (whatsapp.trim().isEmpty) {
      emit(EditProfileError("WhatsApp number is required"));
      return;
    }

    emit(EditProfileLoading());

    try {
      final userId = supabaseClient.auth.currentUser!.id;
      String? finalCvUrl;
      String? finalAvatarUrl;

      // Upload new avatar if picked
      if (_pickedAvatarFile != null) {
        finalAvatarUrl = await editProfileRepo.uploadAvatar(_pickedAvatarFile!);
        if (finalAvatarUrl == null) {
          emit(EditProfileError("Failed to upload profile picture."));
          return;
        }
      }

      // Upload new CV if picked
      if (_pickedCvFile != null) {
        finalCvUrl = await editProfileRepo.uploadCv(_pickedCvFile!);
        if (finalCvUrl == null) {
          emit(EditProfileError("Failed to upload CV."));
          return;
        }
      }

      // Update all profile data in the database
      final success = await editProfileRepo.updateUserInfo(
        userId: userId,
        name: name.trim(),
        jobTitle: jobTitle.trim(),
        level: level,
        typeOfWork: typeOfWork,
        whatsapp: whatsapp.trim(),
        linkedin: linkedin.trim(),
        github: github.trim(),
        cvUrl: finalCvUrl,
        avatarUrl: finalAvatarUrl,
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
