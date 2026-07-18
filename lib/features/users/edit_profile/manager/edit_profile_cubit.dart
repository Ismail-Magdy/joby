import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/repos/edit_profile_repo.dart';
import 'edit_profile_state.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/errors/error_handler.dart';

class EditProfileCubit extends Cubit<EditProfileState> {
  final EditProfileRepo editProfileRepo;
  final SupabaseClient supabaseClient;

  File? _pickedCvFile;
  File? _pickedAvatarFile;

  EditProfileCubit(this.editProfileRepo, this.supabaseClient)
    : super(EditProfileInitial());

  /// Pick an avatar image from the gallery
  Future<void> pickAvatar() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: .gallery);

      if (image != null) {
        final CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: image.path,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: "Crop Image",
              toolbarColor: AppColors.primaryColor,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: false,
            ),
            IOSUiSettings(title: "Crop Image"),
          ],
        );

        if (croppedFile != null) {
          _pickedAvatarFile = File(croppedFile.path);
          emit(EditProfileAvatarPicked(file: _pickedAvatarFile!));
        }
      }
    } catch (error) {
      emit(EditProfileError(ErrorHandler.handleError(error)));
    }
  }

  /// Pick a PDF file from the device
  Future<void> pickCv() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ["pdf"],
      );

      if (result != null && result.files.single.path != null) {
        _pickedCvFile = File(result.files.single.path!);
        final fileName = result.files.single.name;
        emit(EditProfileCvPicked(file: _pickedCvFile!, fileName: fileName));
      }
    } catch (error) {
      emit(EditProfileError(ErrorHandler.handleError(error)));
    }
  }

  /// Save all profile changes to Supabase
  Future<void> saveChanges({
    required String name,
    required String jobTitle,
    required String level,
    required String typeOfWork,
    required String whatsapp,
    required String linkedin,
    required String github,
    required String behance,
  }) async {
    emit(EditProfileLoading());

    try {
      final userId = supabaseClient.auth.currentUser!.id;
      String? finalCvUrl;
      String? finalAvatarUrl;

      // Upload new avatar if picked
      if (_pickedAvatarFile != null) {
        String? rawAvatarUrl = await editProfileRepo.uploadAvatar(
          _pickedAvatarFile!,
        );
        if (rawAvatarUrl == null) {
          emit(EditProfileError("Failed to upload profile picture"));
          return;
        }
        finalAvatarUrl =
            "$rawAvatarUrl?t=${DateTime.now().millisecondsSinceEpoch}";
      }

      // Upload new CV if picked
      if (_pickedCvFile != null) {
        String? rawCvUrl = await editProfileRepo.uploadCv(_pickedCvFile!);
        if (rawCvUrl == null) {
          emit(EditProfileError("Failed to upload CV"));
          return;
        }
        finalCvUrl = "$rawCvUrl?t=${DateTime.now().millisecondsSinceEpoch}";
      }

      // Update profile data — only non-empty fields are sent
      final success = await editProfileRepo.updateUserInfo(
        userId: userId,
        name: name.trim(),
        jobTitle: jobTitle.trim(),
        level: level,
        typeOfWork: typeOfWork,
        whatsapp: whatsapp.trim(),
        linkedin: linkedin.trim(),
        github: github.trim(),
        behance: behance.trim(),
        cvUrl: finalCvUrl,
        avatarUrl: finalAvatarUrl,
      );

      if (success) {
        emit(EditProfileSuccess());
      } else {
        emit(EditProfileError("Failed to update profile data"));
      }
    } catch (error) {
      emit(EditProfileError(ErrorHandler.handleError(error)));
    }
  }
}
