import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ionicons/ionicons.dart';
import 'package:joby/core/helpers/spacing.dart';
import 'package:joby/core/themes/app_colors.dart';
import 'package:joby/features/users/edit_profile/manager/edit_profile_cubit.dart';
import 'package:joby/features/users/edit_profile/manager/edit_profile_state.dart';

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
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Ionicons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // 🔥 بنستخدم BlocConsumer عشان نسمع للـ states (النجاح والإيرور) 🔥
      body: BlocConsumer<EditProfileCubit, EditProfileState>(
        listener: (context, state) {
          if (state is EditProfileCvPicked) {
            setState(() {
              _pickedCvName = state.fileName; // بنحدث اسم الملف في الواجهة
            });
          } else if (state is EditProfileSuccess) {
            // لو نجح، نظهر رسالة ونرجع للهوم ونعمل ريفريش للداتا القديمة
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Profile updated successfully!"),
                backgroundColor: Colors.green,
              ),
            );
            // TODO: ريفريش داتا الهوم (محتاجة نبعت داتا الهوم كيوبت هنا أو نستخدم IndexedStack)
            // context.read<UserHomeCubit>().getUserData(); // لو عاملIndexedStack مش هتحتاج دي
            Navigator.pop(context);
          } else if (state is EditProfileError) {
            // لو حصل إيرور نظهر رسالة
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final cubit = context.read<EditProfileCubit>();
          final isLoading = state is EditProfileLoading;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // صورة البروفايل
                Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 50.r,
                        backgroundColor: Colors.grey.shade100,
                        child: Icon(
                          Ionicons.person,
                          size: 50.sp,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Icon(
                          Ionicons.camera,
                          color: Colors.white,
                          size: 18.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                verticalSpace(40),

                Text(
                  "Social Links",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                verticalSpace(20),

                _buildTextField(
                  controller: _whatsappController,
                  label: "WhatsApp Number (Required)",
                  hint: "eg. 01012345678",
                  icon: Ionicons.logo_whatsapp,
                  iconColor: Colors.green,
                  keyboardType: TextInputType.phone,
                ),
                verticalSpace(15),

                _buildTextField(
                  controller: _linkedinController,
                  label: "LinkedIn URL",
                  hint: "https://linkedin.com/in/username",
                  icon: Ionicons.logo_linkedin,
                  iconColor: const Color(0xff0077B5),
                ),
                verticalSpace(15),

                _buildTextField(
                  controller: _githubController,
                  label: "GitHub URL",
                  hint: "https://github.com/username",
                  icon: Ionicons.logo_github,
                  iconColor: const Color(0xff333333),
                ),

                verticalSpace(30),
                Text(
                  "Resume / CV",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                verticalSpace(15),

                // زرار رفع الـ CV
                GestureDetector(
                  onTap: isLoading
                      ? null
                      : () => cubit.pickCv(), // لو لودينج مينفعش يدوس
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: _pickedCvName != null ? 15.h : 20.h,
                      horizontal: 15.w,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.05),
                      border: Border.all(
                        color: AppColors.primaryColor.withOpacity(0.3),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(16.r),
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
                          _pickedCvName ??
                              "Upload New CV (PDF)", // لو اختار ملف نظهر اسمه
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),

                verticalSpace(50),

                // زرار الحفظ
                SizedBox(
                  width: double.infinity,
                  height: 55.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
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
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          ) // نظهر لودينج
                        : Text(
                            "Save Changes",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                verticalSpace(30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color iconColor,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        verticalSpace(8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13.sp),
            prefixIcon: Icon(icon, color: iconColor, size: 22.sp),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 20.w,
              vertical: 16.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
