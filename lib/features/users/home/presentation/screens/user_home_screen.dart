import "package:dio/dio.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:ionicons/ionicons.dart";
import "package:joby/core/helpers/extensions.dart";
import "package:joby/core/routes/routes.dart";
import "package:joby/features/users/home/presentation/widgets/build_contact_icon_button.dart";
import "package:open_filex/open_filex.dart";
import "package:path_provider/path_provider.dart";
import "package:url_launcher/url_launcher.dart";
import "package:joby/core/helpers/spacing.dart";
import "package:joby/core/themes/app_colors.dart";
import "../../manager/user_home_cubit.dart";
import "../../manager/user_home_state.dart";
import "../widgets/build_badge_widget.dart";
import "../widgets/curve_painter.dart";

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  bool _isDownloadingCv = false;
  @override
  void initState() {
    super.initState();
    context.read<UserHomeCubit>().getUserData();
  }

  ///
  Future<void> _launchUrl(String urlString, {bool isPhone = false}) async {
    Uri url;

    if (isPhone) {
      String cleanedPhone = urlString.replaceAll(RegExp(r"\D"), "");
      if (cleanedPhone.startsWith('01') && cleanedPhone.length == 11) {
        cleanedPhone = '20${cleanedPhone.substring(1)}';
      } else if (!cleanedPhone.startsWith('20') &&
          !cleanedPhone.startsWith('+')) {
        cleanedPhone = '20$cleanedPhone';
      }
      url = Uri.parse("https://wa.me/$cleanedPhone");
    } else {
      String finalUrl = urlString.trim();
      if (!finalUrl.startsWith('http://') && !finalUrl.startsWith('https://')) {
        finalUrl = 'https://$finalUrl';
      }
      url = Uri.parse(finalUrl);
    }

    try {
      if (!await launchUrl(url, mode: .externalApplication)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Could not launch the link"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Invalid link format"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  //

  ///
  Future<void> _downloadAndOpenCV(String urlString) async {
    setState(() {
      _isDownloadingCv = true;
    });

    try {
      final tempDir = await getTemporaryDirectory();
      final savePath =
          '${tempDir.path}/Joby_Resume_${DateTime.now().millisecondsSinceEpoch}.pdf';

      final dio = Dio();
      await dio.download(urlString, savePath);

      final result = await OpenFilex.open(savePath);

      if (result.type != .done) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("No app found to open PDF files"),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error opening CV: $error"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloadingCv = false;
        });
      }
    }
  }

  //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<UserHomeCubit, UserHomeState>(
        builder: (context, state) {
          if (state is UserHomeLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            );
          } else if (state is UserHomeError) {
            return Center(child: Text(state.message));
          } else if (state is UserHomeSuccess) {
            final user = state.userInfo;
            return SingleChildScrollView(
              padding: .only(bottom: 120.h),
              child: Column(
                children: [
                  // Header
                  Stack(
                    clipBehavior: .none,
                    alignment: .center,
                    children: [
                      // Custom Circle
                      CustomPaint(
                        size: Size(.infinity, 120.h),
                        painter: CurvePainter(),
                      ),
                      // Custom App Bar
                      Positioned(
                        top: 40.h,
                        left: 20.w,
                        right: 20.w,
                        child: Row(
                          mainAxisAlignment: .spaceBetween,
                          children: [
                            // Manager Button
                            GestureDetector(
                              onTap: () {
                                // TODO: Company View
                              },
                              child: SvgPicture.asset(
                                "assets/svgs/manager.svg",
                                colorFilter: .mode(Colors.white, .srcIn),
                                height: 22.h,
                              ),
                            ),
                            //
                            // App Bar Title
                            Text(
                              "My Profile",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.sp,
                                fontWeight: .bold,
                                fontFamily: "BrunoAceSC",
                              ),
                            ),
                            //
                            // Pen Button
                            GestureDetector(
                              onTap: () =>
                                  context.pushNamed(Routes.editProfileScreen),
                              child: SvgPicture.asset(
                                "assets/svgs/pen.svg",
                                colorFilter: .mode(Colors.white, .srcIn),
                                height: 22.h,
                              ),
                            ),
                            //
                          ],
                        ),
                      ),
                      // Image
                      Positioned(
                        top: 80.h,
                        child: Container(
                          padding: .all(2.r),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: .circle,
                          ),
                          child: CircleAvatar(
                            radius: 55.r,
                            backgroundColor: Colors.grey.shade100,
                            backgroundImage: user.avatarUrl != null
                                ? NetworkImage(user.avatarUrl!)
                                : null,
                            child: user.avatarUrl == null
                                ? Icon(
                                    Ionicons.person,
                                    size: 40.sp,
                                    color: Colors.grey.shade400,
                                  )
                                : null,
                          ),
                        ),
                      ),
                      //
                    ],
                  ),
                  //
                  verticalSpace(95),
                  //
                  // Name
                  Text(
                    user.name,
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  //
                  verticalSpace(5),
                  // Job Title
                  Text(
                    user.jobTitle,
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  //
                  verticalSpace(25),
                  // Level & Work Type
                  Row(
                    mainAxisAlignment: .center,
                    children: [
                      BuildBadgeWidget(
                        icon: Ionicons.stats_chart_outline,
                        text: user.level,
                      ),
                      horizontalSpace(30),
                      BuildBadgeWidget(
                        icon: Ionicons.location_outline,
                        text: user.typeOfWork,
                      ),
                    ],
                  ),
                  //
                  verticalSpace(50),
                  // Social Media
                  Row(
                    mainAxisAlignment: .center,
                    children: [
                      // Whatsapp
                      BuildContactIconButton(
                        icon: Ionicons.logo_whatsapp,
                        color: Colors.green,
                        onTap: () {
                          if (user.whatsapp.isNotEmpty) {
                            _launchUrl(user.whatsapp, isPhone: true);
                          }
                        },
                      ),
                      //
                      horizontalSpace(20),
                      // Linkedin
                      BuildContactIconButton(
                        icon: Ionicons.logo_linkedin,
                        color: const Color(0xff0077B5),
                        onTap: () {
                          if (user.linkedin != null &&
                              user.linkedin!.isNotEmpty) {
                            _launchUrl(user.linkedin!);
                          }
                        },
                      ),
                      //
                      horizontalSpace(20),
                      // Github
                      BuildContactIconButton(
                        icon: Ionicons.logo_github,
                        color: const Color(0xff333333),
                        onTap: () {
                          if (user.github != null && user.github!.isNotEmpty) {
                            _launchUrl(user.github!);
                          }
                        },
                      ),
                      //
                    ],
                  ),
                  //
                  verticalSpace(30),
                  //
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      crossAxisAlignment: .start,
                      children: [
                        verticalSpace(30),
                        //   CV
                        if (user.cvUrl != null)
                          //
                          GestureDetector(
                            onTap: _isDownloadingCv
                                ? null
                                : () {
                                    _downloadAndOpenCV(user.cvUrl!);
                                  },
                            child: Container(
                              padding: .symmetric(
                                horizontal: 18.w,
                                vertical: 14.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withValues(
                                  alpha: 0.06,
                                ),
                                borderRadius: .circular(16.r),
                                border: .all(
                                  color: AppColors.primaryColor.withValues(
                                    alpha: 0.15,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: .all(10.r),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: .circular(10.r),
                                    ),
                                    child: Icon(
                                      Ionicons.document_text_outline,
                                      color: AppColors.primaryColor,
                                      size: 26.sp,
                                    ),
                                  ),
                                  //
                                  horizontalSpace(15),
                                  //
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: .start,
                                      children: [
                                        //
                                        Text(
                                          "My Resume",
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        //
                                        verticalSpace(3),
                                        //
                                        Text(
                                          "PDF Document",
                                          style: TextStyle(
                                            fontSize: 13.sp,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        //
                                      ],
                                    ),
                                  ),
                                  //
                                  Icon(
                                    Ionicons.eye_outline,
                                    color: AppColors.primaryColor,
                                    size: 22.sp,
                                  ),
                                  //
                                ],
                              ),
                            ),
                          ),
                        //
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
