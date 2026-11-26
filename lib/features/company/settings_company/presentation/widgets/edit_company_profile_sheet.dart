import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:joby/core/helpers/spacing.dart';
import 'package:joby/core/themes/app_colors.dart';
import 'package:joby/core/widgets/custom_feedback_dialog.dart';
import '../../manager/company_settings_cubit.dart';
import '../../manager/company_settings_state.dart';

class EditCompanyProfileSheet extends StatefulWidget {
  final String initialName;
  final String? initialAvatarUrl;

  const EditCompanyProfileSheet({
    super.key,
    required this.initialName,
    this.initialAvatarUrl,
  });

  @override
  State<EditCompanyProfileSheet> createState() =>
      _EditCompanyProfileSheetState();
}

class _EditCompanyProfileSheetState extends State<EditCompanyProfileSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  File? _pickedAvatarFile;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null || !mounted) return;

    String cleanPath = image.path;
    if (cleanPath.startsWith('file://')) {
      try {
        cleanPath = Uri.parse(cleanPath).toFilePath();
      } catch (_) {
        cleanPath = cleanPath.replaceFirst('file://', '');
      }
    }

    setState(() {
      _pickedAvatarFile = File(cleanPath);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CompanySettingsCubit, CompanySettingsState>(
      listenWhen: (previous, current) =>
          current.profileSaveSuccess != previous.profileSaveSuccess ||
          current.profileError != previous.profileError,
      listener: (context, state) {
        if (state.profileSaveSuccess) {
          Navigator.of(context).pop();
          CustomFeedbackDialog.showSuccess(
            context,
            title: "Profile Updated",
            message: "Company Name And Logo Updated Successfully",
          );
        } else if (state.profileError != null) {
          CustomFeedbackDialog.showError(
            context,
            title: "Update Failed",
            message: state.profileError!,
          );
        }
      },
      builder: (context, state) {
        return Padding(
          padding: .only(
            left: 24.w,
            right: 24.w,
            top: 20.h,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: .min,
              children: [
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: .circular(10.r),
                  ),
                ),
                verticalSpace(18),
                Text(
                  "Edit Company Profile",
                  style: TextStyle(
                    fontFamily: 'BrunoAceSC',
                    fontSize: 17.sp,
                    fontWeight: .bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                verticalSpace(20),
                // Input 1: Company Profile Photo Picker
                GestureDetector(
                  onTap: state.isSavingProfile ? null : _pickLogo,
                  child: Stack(
                    alignment: .bottomRight,
                    children: [
                      Container(
                        width: 96.w,
                        height: 96.w,
                        decoration: BoxDecoration(
                          shape: .circle,
                          color: AppColors.primaryColor.withValues(alpha: 0.08),
                          border: .all(
                            color: AppColors.primaryColor.withValues(
                              alpha: 0.3,
                            ),
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: _pickedAvatarFile != null
                              ? Image.file(
                                  _pickedAvatarFile!,
                                  fit: BoxFit.cover,
                                )
                              : (widget.initialAvatarUrl != null &&
                                    widget.initialAvatarUrl!.isNotEmpty)
                              ? CachedNetworkImage(
                                  imageUrl: widget.initialAvatarUrl!,
                                  fit: BoxFit.cover,
                                  placeholder: (_, _) => const Center(
                                    child: CupertinoActivityIndicator(),
                                  ),
                                  errorWidget: (_, _, _) => Icon(
                                    Icons.business_rounded,
                                    size: 42.sp,
                                    color: AppColors.primaryColor,
                                  ),
                                )
                              : Icon(
                                  Icons.business_rounded,
                                  size: 42.sp,
                                  color: AppColors.primaryColor,
                                ),
                        ),
                      ),
                      Container(
                        padding: .all(7.r),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          shape: .circle,
                          border: .all(color: Colors.white, width: 2),
                        ),
                        child: Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 16.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                verticalSpace(22),
                // Input 2: Company Name Text Field
                TextFormField(
                  controller: _nameController,
                  enabled: !state.isSavingProfile,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Company Name',
                    prefixIcon: const Icon(Icons.business_outlined),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: .circular(14.r),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: .circular(14.r),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: .circular(14.r),
                      borderSide: const BorderSide(
                        color: AppColors.primaryColor,
                        width: 1.5,
                      ),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please Enter Company Name';
                    }
                    return null;
                  },
                ),
                verticalSpace(22),
                SizedBox(
                  width: .infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: state.isSavingProfile
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              context
                                  .read<CompanySettingsCubit>()
                                  .updateCompanyProfile(
                                    name: _nameController.text,
                                    newAvatarFile: _pickedAvatarFile,
                                  );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: .circular(14.r),
                      ),
                      elevation: 0,
                    ),
                    child: state.isSavingProfile
                        ? const CupertinoActivityIndicator(color: Colors.white)
                        : Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: .w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
