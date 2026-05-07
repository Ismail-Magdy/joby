import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:joby/core/helpers/constants.dart';
import 'package:joby/core/helpers/shared_prefrences_helper.dart';
import 'package:joby/core/themes/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/repos/company_info_repo.dart';
import 'company_info_state.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/material.dart';

class CompanyInfoCubit extends Cubit<CompanyInfoState> {
  final CompanyInfoRepo companyInfoRepo;
  final SupabaseClient supabaseClient;

  CompanyInfoCubit({
    required this.companyInfoRepo,
    required this.supabaseClient,
  }) : super(CompanyInfoInitial());

  File? profileImage;
  String? prefilledName;
  String? prefilledAvatarUrl;

  void fetchInitialData() {
    final user = supabaseClient.auth.currentUser;
    if (user != null) {
      prefilledName =
          user.userMetadata?["name"] ?? user.userMetadata?["full_name"];
      prefilledAvatarUrl =
          user.userMetadata?["avatar_url"] ?? user.userMetadata?["picture"];

      emit(CompanyInfoInitial());
    }
  }

  Future<void> pickAndCropAvatar() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: .gallery);

    if (image != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: "Crop Company Logo",
            toolbarColor: AppColors.primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: "Crop Company Logo",
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
          ),
        ],
      );

      if (croppedFile != null) {
        profileImage = File(croppedFile.path);
        emit(CompanyInfoAvatarPicked(croppedFile.path));
      }
    }
  }

  Future<void> completeInfo({required String name}) async {
    emit(CompanyInfoLoading());

    final result = await companyInfoRepo.completeCompanyInfo(
      name: name,
      profileImageFile: profileImage,
      profileImageUrl: prefilledAvatarUrl,
    );

    result.fold((error) => emit(CompanyInfoError(error)), (_) async {
      await SharedPrefHelper.setData(
        AppConstants.isCompanyInfoCompletedKey,
        true,
      );
      emit(CompanyInfoSuccess());
    });
  }
}
