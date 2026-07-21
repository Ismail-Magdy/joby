import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:joby/core/helpers/extensions.dart';
import 'package:joby/core/helpers/spacing.dart';
import 'package:joby/core/routes/routes.dart';
import 'package:joby/core/themes/app_colors.dart';
import 'package:joby/core/widgets/custom_text_field.dart';
import 'package:joby/core/widgets/exit_confirmation_wrapper.dart';
import 'package:joby/core/widgets/snack_bar_text.dart';
import 'package:joby/features/company/company_info/manager/company_info_cubit.dart';
import 'package:joby/features/company/company_info/manager/company_info_state.dart';
import 'package:joby/features/company/company_info/presentation/widgets/custom_setup_company_button.dart';

class CompanyInfoScreen extends StatefulWidget {
  const CompanyInfoScreen({super.key});

  @override
  State<CompanyInfoScreen> createState() => _CompanyInfoScreenState();
}

class _CompanyInfoScreenState extends State<CompanyInfoScreen> {
  final TextEditingController _nameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final cubit = context.read<CompanyInfoCubit>();
    cubit.fetchInitialData();
    if (cubit.prefilledName != null) {
      _nameController.text = cubit.prefilledName!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExitConfirmationWrapper(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: BlocConsumer<CompanyInfoCubit, CompanyInfoState>(
            listener: (context, state) {
              if (state is CompanyInfoSuccess) {
                context.pushNamedAndRemoveUntil(
                  Routes.companyRootScreen,
                  predicate: (Route<dynamic> route) => false,
                );
              } else if (state is CompanyInfoError) {
                // Show error message in a SnackBar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: SnackBarText(title: state.message),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    margin: .all(20.r),
                    shape: RoundedRectangleBorder(
                      borderRadius: .circular(10.r),
                    ),
                  ),
                );
                //
              }
            },
            builder: (context, state) {
              final cubit = context.read<CompanyInfoCubit>();
              return SingleChildScrollView(
                padding: .symmetric(horizontal: 24.w, vertical: 30.h),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: .center,
                    children: [
                      //
                      verticalSpace(20),
                      // Title
                      Text(
                        "Setup Company Profile",
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: .bold,
                          color: AppColors.primaryColor,
                          fontFamily: "BrunoAceSC",
                        ),
                      ),
                      //
                      verticalSpace(10),
                      // Subtitle
                      Text(
                        "Let's get your company ready to hire top talent",
                        textAlign: .center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey.shade600,
                          height: 1.5,
                        ),
                      ),
                      //
                      verticalSpace(40),
                      // Profile Picture Section
                      GestureDetector(
                        onTap: () => cubit.pickAndCropAvatar(),
                        child: Stack(
                          alignment: .bottomRight,
                          children: [
                            // Avatar Container
                            Container(
                              height: 120.h,
                              width: 120.h,
                              decoration: BoxDecoration(
                                shape: .circle,
                                color: Colors.grey.shade200,
                                border: .all(
                                  color: AppColors.primaryColor.withValues(
                                    alpha: 0.5,
                                  ),
                                  width: 2,
                                ),
                              ),
                              child: ClipOval(child: _buildProfileImage(cubit)),
                            ),
                            //
                            CircleAvatar(
                              radius: 20.r,
                              backgroundColor: AppColors.primaryColor,
                              child: SvgPicture.asset(
                                cubit.profileImage == null
                                    ? "assets/svgs/camera.svg"
                                    : "assets/svgs/pen_edit.svg",
                                colorFilter: .mode(Colors.white, .srcIn),
                              ),
                            ),
                            //
                          ],
                        ),
                      ),
                      //
                      verticalSpace(40),
                      // Name Section
                      CustomTextFormField(
                        controller: _nameController,
                        hintText: "Company or Manager Name",
                        fieldType: .normal,
                        prefixIcon: Icons.business,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Please enter a name";
                          }
                          return null;
                        },
                      ),
                      //
                      verticalSpace(50),
                      //
                      // Submit Button
                      CustomSetupCompanyButton(
                        onPressed: state is CompanyInfoLoading
                            ? null
                            : () {
                                //
                                if (cubit.profileImage == null &&
                                    cubit.prefilledAvatarUrl == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const SnackBarText(
                                        title: "Please upload a company logo",
                                      ),
                                      backgroundColor: Colors.red,
                                      behavior: SnackBarBehavior.floating,
                                      margin: .all(20.r),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: .circular(10.r),
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                if (_formKey.currentState!.validate()) {
                                  cubit.completeInfo(
                                    name: _nameController.text.trim(),
                                  );
                                }
                              },
                        child: state is CompanyInfoLoading
                            ? const CupertinoActivityIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                "Complete Setup",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: .bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                      //
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage(CompanyInfoCubit cubit) {
    if (cubit.profileImage != null) {
      return Image.file(cubit.profileImage!, fit: .cover);
    } else if (cubit.prefilledAvatarUrl != null) {
      return CachedNetworkImage(
        imageUrl: cubit.prefilledAvatarUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => const CupertinoActivityIndicator(),
        errorWidget: (context, url, error) =>
            Icon(Icons.business, size: 50.sp, color: Colors.grey.shade400),
      );
    } else {
      return Icon(Icons.business, size: 50.sp, color: Colors.grey.shade400);
    }
  }
}
