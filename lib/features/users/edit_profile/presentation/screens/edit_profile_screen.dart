import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ionicons/ionicons.dart';
import 'package:joby/core/helpers/extensions.dart';
import 'package:joby/core/helpers/spacing.dart';
import 'package:joby/core/themes/app_colors.dart';
import 'package:joby/features/users/edit_profile/manager/edit_profile_cubit.dart';
import 'package:joby/features/users/edit_profile/manager/edit_profile_state.dart';
import 'package:joby/features/users/edit_profile/presentation/widgets/build_text_field.dart';
import 'package:joby/features/users/edit_profile/presentation/widgets/drop_down_widget.dart';
import 'package:joby/features/users/user_info/data/models/user_info_model.dart';

class EditProfileScreen extends StatefulWidget {
  final UserInfoModel? currentUserInfo;

  const EditProfileScreen({super.key, this.currentUserInfo});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Personal info controllers
  final _nameController = TextEditingController();
  final _jobTitleController = TextEditingController();

  // Social link controllers
  final _whatsappController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _githubController = TextEditingController();

  // Dropdown selections
  String? _selectedLevel;
  String? _selectedWorkType;

  // Avatar
  File? _pickedAvatarFile;

  // CV
  String? _pickedCvName;

  // Track initial values for change detection
  late final String _initialName;
  late final String _initialJobTitle;
  late final String _initialWhatsapp;
  late final String _initialLinkedin;
  late final String _initialGithub;
  late final String? _initialLevel;
  late final String? _initialWorkType;

  // Dropdown options (same as user_info_screen.dart)
  static const List<String> _levelOptions = [
    "Junior",
    "Mid-Level",
    "Senior",
    "Lead",
  ];
  //
  static const List<String> _workTypeOptions = ["Remote", "On-site", "Hybrid"];

  @override
  void initState() {
    super.initState();
    _prefillFields();
  }

  /// Pre-fill all controllers & dropdowns with existing user data.
  void _prefillFields() {
    final user = widget.currentUserInfo;
    if (user != null) {
      _nameController.text = user.name;
      _jobTitleController.text = user.jobTitle;
      _whatsappController.text = user.whatsapp;
      _linkedinController.text = user.linkedin ?? "";
      _githubController.text = user.github ?? "";

      // Only set dropdown if value is valid
      if (_levelOptions.contains(user.level)) {
        _selectedLevel = user.level;
      }
      if (_workTypeOptions.contains(user.typeOfWork)) {
        _selectedWorkType = user.typeOfWork;
      }
    }

    // Store initial values for change detection
    _initialName = _nameController.text;
    _initialJobTitle = _jobTitleController.text;
    _initialWhatsapp = _whatsappController.text;
    _initialLinkedin = _linkedinController.text;
    _initialGithub = _githubController.text;
    _initialLevel = _selectedLevel;
    _initialWorkType = _selectedWorkType;
  }

  /// Check if any field has been modified from its initial value.
  bool get _hasUnsavedChanges {
    return _nameController.text != _initialName ||
        _jobTitleController.text != _initialJobTitle ||
        _whatsappController.text != _initialWhatsapp ||
        _linkedinController.text != _initialLinkedin ||
        _githubController.text != _initialGithub ||
        _selectedLevel != _initialLevel ||
        _selectedWorkType != _initialWorkType ||
        _pickedAvatarFile != null ||
        _pickedCvName != null;
  }

  /// Show a confirmation dialog when the user tries to leave with unsaved changes.
  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: .circular(20.r)),
        //
        title: Text(
          "Unsaved Changes",
          style: TextStyle(
            fontFamily: "BrunoAceSC",
            fontSize: 18.sp,
            fontWeight: .bold,
          ),
        ),
        //
        content: Text(
          "You have unsaved changes. What would you like to do?",
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey.shade700,
            height: 1.5,
          ),
        ),
        //
        actions: [
          // Discard Button
          TextButton(
            onPressed: () => Navigator.pop(context, "discard"),
            child: Text(
              "Discard",
              style: TextStyle(
                color: Colors.red.shade400,
                fontSize: 14.sp,
                fontWeight: .w600,
              ),
            ),
          ),
          //
          // Save Button
          ElevatedButton(
            onPressed: () => Navigator.pop(context, "save"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: .circular(12.r)),
              elevation: 0,
              padding: .symmetric(horizontal: 20.w, vertical: 10.h),
            ),
            child: Text(
              "Save Changes",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: .w600,
              ),
            ),
          ),
          //
        ],
      ),
    );

    if (result == "save") {
      _triggerSave();
      return false;
    }

    return result == "discard";
  }

  /// Trigger the save via cubit.
  void _triggerSave() {
    context.read<EditProfileCubit>().saveChanges(
      name: _nameController.text,
      jobTitle: _jobTitleController.text,
      level: _selectedLevel ?? "",
      typeOfWork: _selectedWorkType ?? "",
      whatsapp: _whatsappController.text,
      linkedin: _linkedinController.text,
      github: _githubController.text,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _jobTitleController.dispose();
    _whatsappController.dispose();
    _linkedinController.dispose();
    _githubController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      //
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          context.pop();
        }
      },
      //
      child: Scaffold(
        backgroundColor: Colors.white,
        // App Bar
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          title: Text(
            "Edit Profile",
            style: TextStyle(
              color: Colors.black87,
              fontSize: 20.sp,
              fontWeight: .bold,
              fontFamily: "BrunoAceSC",
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
            onPressed: () async {
              final shouldPop = await _onWillPop();
              if (shouldPop && context.mounted) {
                context.pop();
              }
            },
          ),
        ),
        //
        body: BlocConsumer<EditProfileCubit, EditProfileState>(
          //
          listener: (context, state) {
            if (state is EditProfileAvatarPicked) {
              setState(() {
                _pickedAvatarFile = state.file;
              });
            } else if (state is EditProfileCvPicked) {
              setState(() {
                _pickedCvName = state.fileName;
              });
            } else if (state is EditProfileSuccess) {
              //
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Center(child: Text("Profile updated successfully")),
                  backgroundColor: Colors.green,
                  margin: EdgeInsets.all(20.r),
                  shape: RoundedRectangleBorder(borderRadius: .circular(10.r)),
                ),
              );
              // Pop with `true` so the home screen knows to refresh
              Navigator.pop(context, true);
            } else if (state is EditProfileError) {
              //
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Center(child: Text(state.message)),
                  backgroundColor: Colors.red,
                  margin: EdgeInsets.all(20.r),
                  shape: RoundedRectangleBorder(borderRadius: .circular(10.r)),
                ),
              );
              //
            }
          },
          //
          builder: (context, state) {
            final cubit = context.read<EditProfileCubit>();
            final isLoading = state is EditProfileLoading;

            return SingleChildScrollView(
              padding: .symmetric(horizontal: 24.w, vertical: 20.h),
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  // Avatar
                  Center(
                    child: Stack(
                      alignment: .bottomRight,
                      children: [
                        // Image - shows picked file, or network avatar, or fallback icon
                        CircleAvatar(
                          radius: 50.r,
                          backgroundColor: Colors.grey.shade100,
                          backgroundImage: _buildAvatarImage(),
                          child: _shouldShowAvatarPlaceholder()
                              ? Icon(
                                  Ionicons.person,
                                  size: 50.sp,
                                  color: Colors.grey.shade400,
                                )
                              : null,
                        ),
                        //
                        // Camera Icon - opens gallery
                        GestureDetector(
                          onTap: isLoading ? null : () => cubit.pickAvatar(),
                          child: Container(
                            padding: .all(8.r),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              shape: .circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: SvgPicture.asset(
                              "assets/svgs/camera.svg",
                              colorFilter: .mode(Colors.white, .srcIn),
                              height: 18.h,
                            ),
                          ),
                        ),
                        //
                      ],
                    ),
                  ),
                  //
                  verticalSpace(40),
                  //
                  //  Personal Info Section
                  Text(
                    "Personal Info",
                    style: TextStyle(fontSize: 18.sp, fontWeight: .bold),
                  ),
                  //
                  verticalSpace(20),
                  //
                  // Name
                  BuildTextField(
                    controller: _nameController,
                    label: "Full Name",
                    hint: "eg. Ahmed Mohamed",
                    icon: Ionicons.person_outline,
                    iconColor: AppColors.primaryColor,
                  ),
                  //
                  verticalSpace(15),
                  //
                  // Job Title
                  BuildTextField(
                    controller: _jobTitleController,
                    label: "Job Title",
                    hint: "eg. Flutter Developer",
                    icon: Ionicons.briefcase_outline,
                    iconColor: AppColors.primaryColor,
                  ),
                  //
                  verticalSpace(15),
                  //
                  // Level Dropdown
                  _buildSectionLabel("Level"),
                  //
                  verticalSpace(8),
                  //
                  DropDownWidget(
                    value: _selectedLevel,
                    hint: "Select your level",
                    icon: Ionicons.stats_chart_outline,
                    items: _levelOptions,
                    onChanged: (val) => setState(() => _selectedLevel = val),
                  ),
                  //
                  verticalSpace(15),
                  //
                  // Work Type Dropdown
                  _buildSectionLabel("Type of Work"),
                  //
                  verticalSpace(8),
                  //
                  DropDownWidget(
                    value: _selectedWorkType,
                    hint: "Select work type",
                    icon: Ionicons.location_outline,
                    items: _workTypeOptions,
                    onChanged: (val) => setState(() => _selectedWorkType = val),
                  ),
                  //
                  verticalSpace(30),
                  //
                  //  Social Links Section
                  Text(
                    "Social Links",
                    style: TextStyle(fontSize: 18.sp, fontWeight: .bold),
                  ),
                  //
                  verticalSpace(20),
                  //
                  BuildTextField(
                    controller: _whatsappController,
                    label: "WhatsApp Number",
                    hint: "eg. 01012345678",
                    icon: Ionicons.logo_whatsapp,
                    iconColor: Colors.green,
                    keyboardType: .phone,
                  ),
                  //
                  verticalSpace(15),
                  //
                  BuildTextField(
                    controller: _linkedinController,
                    label: "LinkedIn URL",
                    hint: "https://linkedin.com/in/username",
                    icon: Ionicons.logo_linkedin,
                    iconColor: const Color(0xff0077B5),
                  ),
                  //
                  verticalSpace(15),
                  //
                  BuildTextField(
                    controller: _githubController,
                    label: "GitHub URL",
                    hint: "https://github.com/username",
                    icon: Ionicons.logo_github,
                    iconColor: const Color(0xff333333),
                  ),
                  //
                  verticalSpace(30),
                  //
                  //  CV Section
                  Text(
                    "CV",
                    style: TextStyle(fontSize: 18.sp, fontWeight: .bold),
                  ),
                  //
                  verticalSpace(15),
                  //
                  // CV Upload
                  GestureDetector(
                    onTap: isLoading ? null : () => cubit.pickCv(),
                    child: Container(
                      width: .infinity,
                      padding: .symmetric(
                        vertical: _pickedCvName != null ? 15.h : 20.h,
                        horizontal: 15.w,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withValues(alpha: 0.05),
                        border: .all(
                          color: AppColors.primaryColor.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                        borderRadius: .circular(16.r),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            _pickedCvName != null
                                ? Ionicons.document_text
                                : Ionicons.cloud_upload_outline,
                            color: AppColors.primaryColor,
                            size: 35.sp,
                          ),
                          verticalSpace(10),
                          Text(
                            _pickedCvName ?? "Upload New CV (PDF)",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.primaryColor,
                              fontWeight: .w600,
                            ),
                            textAlign: .center,
                            maxLines: 1,
                            overflow: .ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                  //
                  verticalSpace(50),
                  //
                  //  Save Button
                  SizedBox(
                    width: .infinity,
                    height: 55.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: .circular(16.r),
                        ),
                        elevation: 0,
                      ),
                      onPressed: isLoading ? null : _triggerSave,
                      child: isLoading
                          ? const CupertinoActivityIndicator(color: Colors.white)
                          : Text(
                              "Save Changes",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: .bold,
                              ),
                            ),
                    ),
                  ),
                  //
                  verticalSpace(30),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Returns the appropriate avatar image provider.
  ImageProvider? _buildAvatarImage() {
    // Priority: picked file → existing network URL → null
    if (_pickedAvatarFile != null) {
      return FileImage(_pickedAvatarFile!);
    }
    final url = widget.currentUserInfo?.avatarUrl;
    if (url != null && url.isNotEmpty) {
      return CachedNetworkImageProvider(url);
    }
    return null;
  }

  /// Whether to show the fallback person icon in the avatar.
  bool _shouldShowAvatarPlaceholder() {
    if (_pickedAvatarFile != null) return false;
    final url = widget.currentUserInfo?.avatarUrl;
    return url == null || url.isEmpty;
  }

  /// Builds a styled section label for dropdown fields.
  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: .w600,
        color: Colors.grey.shade700,
      ),
    );
  }
}
