import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ionicons/ionicons.dart';
import 'package:joby/core/helpers/spacing.dart';
import 'package:joby/core/themes/app_colors.dart';
import 'package:joby/features/users/edit_profile/manager/edit_profile_cubit.dart';
import 'package:joby/features/users/edit_profile/manager/edit_profile_state.dart';
import 'package:joby/features/users/edit_profile/presentation/widgets/build_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _whatsappController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _githubController = TextEditingController();

  String? _pickedCvName;

  @override
  void dispose() {
    _whatsappController.dispose();
    _linkedinController.dispose();
    _githubController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      //
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
          onPressed: () => Navigator.pop(context),
        ),
      ),
      //
      body: BlocConsumer<EditProfileCubit, EditProfileState>(
        listener: (context, state) {
          if (state is EditProfileCvPicked) {
            setState(() {
              _pickedCvName = state.fileName;
            });
          } else if (state is EditProfileSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                behavior: .floating,
                content: Center(child: Text("Profile updated successfully")),
                backgroundColor: Colors.green,
              ),
            );
            // TODO: ريفريش داتا الهوم (محتاجة نبعت داتا الهوم كيوبت هنا أو نستخدم IndexedStack)
            // context.read<UserHomeCubit>().getUserData(); // لو عاملIndexedStack مش هتحتاج دي
            Navigator.pop(context);
          } else if (state is EditProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: .floating,
                content: Center(child: Text(state.message)),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final cubit = context.read<EditProfileCubit>();
          final isLoading = state is EditProfileLoading;

          return SingleChildScrollView(
            padding: .symmetric(horizontal: 24.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Center(
                  child: Stack(
                    alignment: .bottomRight,
                    children: [
                      // Image
                      CircleAvatar(
                        radius: 50.r,
                        backgroundColor: Colors.grey.shade100,
                        child: Icon(
                          Ionicons.person,
                          size: 50.sp,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      //
                      // Camera Icon
                      Container(
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
                      //
                    ],
                  ),
                ),
                //
                verticalSpace(40),
                //
                Text(
                  "Social Links",
                  style: TextStyle(fontSize: 18.sp, fontWeight: .bold),
                ),
                //
                verticalSpace(20),
                //
                BuildTextField(
                  controller: _whatsappController,
                  label: "WhatsApp Number (Required)",
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
                Text(
                  "CV",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                //
                verticalSpace(15),

                // CV
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
                    onPressed: isLoading
                        ? null
                        : () {
                            cubit.saveChanges(
                              whatsapp: _whatsappController.text,
                              linkedin: _linkedinController.text,
                              github: _githubController.text,
                            );
                          },
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
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
    );
  }
}
