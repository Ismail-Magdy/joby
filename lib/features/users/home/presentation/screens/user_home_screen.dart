import "package:dio/dio.dart";
import "package:flutter/material.dart";
import "package:joby/features/users/home/presentation/widgets/custom_info_row.dart";
import "package:joby/features/users/home/presentation/widgets/cv_section.dart";
import "package:joby/features/users/home/presentation/widgets/location_map_section.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";
import "package:joby/core/helpers/extensions.dart";
import "package:joby/core/routes/routes.dart";
import "package:joby/core/widgets/error_screen.dart";
import "package:joby/core/widgets/home_shimmer_loading.dart";
import "package:joby/features/users/home/presentation/widgets/social_media_row.dart";
import "package:joby/features/users/home/presentation/widgets/total_points_container.dart";
import "package:joby/features/users/points/manager/points_cubit.dart";
import "package:joby/features/users/points/manager/points_state.dart";
import "package:joby/features/users/points/presentation/widgets/points_celebration_dialog.dart";
import "package:open_filex/open_filex.dart";
import "package:path_provider/path_provider.dart";
import "package:url_launcher/url_launcher.dart";
import "package:joby/core/helpers/spacing.dart";
import "package:joby/core/themes/app_colors.dart";
import "../../manager/user_home_cubit.dart";
import "../../manager/user_home_state.dart";
import '../widgets/profile_header_delegate.dart';
import '../../../../../core/errors/error_handler.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  bool _isDownloadingCv = false;
  bool _isAvatarLoading = false;
  String? _loadedAvatarUrl;

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
      if (cleanedPhone.startsWith("01") && cleanedPhone.length == 11) {
        cleanedPhone = "20${cleanedPhone.substring(1)}";
      } else if (!cleanedPhone.startsWith("20") &&
          !cleanedPhone.startsWith("+")) {
        cleanedPhone = "20$cleanedPhone";
      }
      url = Uri.parse("https://wa.me/$cleanedPhone");
    } else {
      String finalUrl = urlString.trim();
      if (!finalUrl.startsWith("http://") && !finalUrl.startsWith("https://")) {
        finalUrl = "https://$finalUrl";
      }
      url = Uri.parse(finalUrl);
    }

    try {
      if (!await launchUrl(url, mode: .externalApplication)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Center(child: const Text("Could not launch the link")),
              backgroundColor: Colors.red,
              margin: EdgeInsets.all(20.r),
              shape: RoundedRectangleBorder(
                borderRadius: .all(.circular(10.r)),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Center(child: const Text("Invalid link format")),
            backgroundColor: Colors.red,
            margin: EdgeInsets.all(20.r),
            shape: RoundedRectangleBorder(borderRadius: .all(.circular(10.r))),
          ),
        );
      }
    }
  }

  ///
  Future<void> _downloadAndOpenCV(String urlString) async {
    setState(() {
      _isDownloadingCv = true;
    });

    try {
      final tempDir = await getTemporaryDirectory();
      final savePath =
          "${tempDir.path}/Joby_Resume_${DateTime.now().millisecondsSinceEpoch}.pdf";

      final dio = Dio();
      await dio.download(urlString, savePath);

      final result = await OpenFilex.open(savePath);

      if (result.type != .done) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Center(
                child: const Text("No app found to open PDF files"),
              ),
              backgroundColor: Colors.orange,
              margin: EdgeInsets.all(20.r),
              shape: RoundedRectangleBorder(
                borderRadius: .all(.circular(10.r)),
              ),
            ),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Center(child: Text(ErrorHandler.handleError(error))),
            backgroundColor: Colors.red,
            margin: EdgeInsets.all(20.r),
            shape: RoundedRectangleBorder(borderRadius: .all(.circular(10.r))),
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

      body: BlocListener<PointsCubit, PointsState>(
        //
        listener: (context, state) {
          if (state is PointsClaimCelebration) {
            //
            showGeneralDialog(
              context: context,
              barrierDismissible: true,
              barrierLabel: "Celebration",
              pageBuilder: (context, anim1, anim2) {
                return PointsCelebrationDialog(
                  pointsGained: state.pointsGained,
                );
              },
            );
            //
          } else if (state is PointsClaimError) {
            //
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Center(
                  child: Text(
                    "RPC Error: ${state.message}",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                backgroundColor: Colors.red,
                margin: EdgeInsets.all(20.r),
                shape: RoundedRectangleBorder(
                  borderRadius: .all(.circular(10.r)),
                ),
              ),
            );
            //
          } else if (state is PointsClaimAlreadyClaimed) {
            //
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Center(
                  child: const Text(
                    "Points Already claimed",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                backgroundColor: AppColors.primaryColor,
                margin: EdgeInsets.all(20.r),
                shape: RoundedRectangleBorder(
                  borderRadius: .all(.circular(10.r)),
                ),
              ),
            );
            //
          }
        },
        //
        child: BlocConsumer<UserHomeCubit, UserHomeState>(
          listener: (context, userState) {
            if (userState is UserHomeSuccess) {
              // Track avatar loading
              if (userState.userInfo.avatarUrl != null &&
                  userState.userInfo.avatarUrl != _loadedAvatarUrl) {
                setState(() {
                  _isAvatarLoading = true;
                });

                precacheImage(
                      NetworkImage(userState.userInfo.avatarUrl!),
                      context,
                    )
                    .then((_) {
                      if (mounted) {
                        setState(() {
                          _isAvatarLoading = false;
                          _loadedAvatarUrl = userState.userInfo.avatarUrl;
                        });
                      }
                    })
                    .catchError((_) {
                      if (mounted) {
                        setState(() {
                          _isAvatarLoading = false;
                        });
                      }
                    });
              }

              // Pass the exact contextual instance of UserHomeCubit so UI updates instantly
              context.read<PointsCubit>().claimDailyPoints(
                context.read<UserHomeCubit>(),
              );
            }
          },
          builder: (context, state) {
            // Loading State
            if (state is UserHomeLoading || _isAvatarLoading) {
              return const HomeShimmerLoading();
            }
            // Error State
            else if (state is UserHomeError) {
              return ErrorScreen(errorText: state.message);
            }
            // Success State
            else if (state is UserHomeSuccess) {
              final user = state.userInfo;
              return CustomScrollView(
                slivers: [
                  // Animated collapsing header
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: ProfileHeaderDelegate(
                      avatarUrl: user.avatarUrl,
                      title: "My Profile",
                      name: user.name,
                      jobTitle: user.jobTitle,
                      onManagerTap: () =>
                          context.pushNamed(Routes.companyViewScreen),
                      onEditTap: () async {
                        final result = await context.pushNamed(
                          Routes.editProfileScreen,
                          arguments: user,
                        );
                        if (result == true && mounted) {
                          // ignore: use_build_context_synchronously
                          context.read<UserHomeCubit>().getUserData();
                        }
                      },
                    ),
                  ),
                  // Body content
                  SliverPadding(
                    padding: .only(bottom: 140.h),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        children: [
                          //
                          verticalSpace(70),
                          // Name
                          Text(
                            user.name,
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: .bold,
                              color: Colors.black87,
                            ),
                          ),
                          verticalSpace(5),
                          // Job Title
                          Text(
                            user.jobTitle,
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: Colors.grey.shade600,
                              fontWeight: .w500,
                            ),
                          ),
                          //
                          verticalSpace(15),
                          // Total Points
                          TotalPointsContainer(
                            text: user.totalPoints.toString(),
                          ),
                          //
                          verticalSpace(25),
                          // Level, Job Category, & Work Type
                          SingleChildScrollView(
                            scrollDirection: .horizontal,
                            physics: BouncingScrollPhysics(),
                            child: CustomInfoRow(
                              levelText: user.level,
                              jobCategoryText: user.jobCategory,
                              typeOfWorkText: user.typeOfWork,
                            ),
                          ),
                          //
                          verticalSpace(50),
                          // Social Media
                          SocialMediaRow(
                            showLinkedin:
                                user.linkedin != null &&
                                user.linkedin!.isNotEmpty,
                            showGithub:
                                user.github != null && user.github!.isNotEmpty,
                            showBehance:
                                user.behance != null &&
                                user.behance!.isNotEmpty,
                            whatsappTap: () {
                              if (user.whatsapp.isNotEmpty) {
                                _launchUrl(user.whatsapp, isPhone: true);
                              }
                            },
                            linkedinTap: () {
                              if (user.linkedin != null &&
                                  user.linkedin!.isNotEmpty) {
                                _launchUrl(user.linkedin!);
                              }
                            },
                            githubTap: () {
                              if (user.github != null &&
                                  user.github!.isNotEmpty) {
                                _launchUrl(user.github!);
                              }
                            },
                            behanceTap: () {
                              if (user.behance != null &&
                                  user.behance!.isNotEmpty) {
                                _launchUrl(user.behance!);
                              }
                            },
                          ),
                          //
                          verticalSpace(20),
                          // CV Section
                          Padding(
                            padding: .symmetric(horizontal: 24.w),
                            child: Column(
                              crossAxisAlignment: .start,
                              children: [
                                //
                                verticalSpace(30),
                                //
                                if (user.cvUrl != null)
                                  //
                                  CvSection(
                                    onTap: _isDownloadingCv
                                        ? null
                                        : () => _downloadAndOpenCV(user.cvUrl!),
                                  ),
                                //
                              ],
                            ),
                          ),
                          //
                          // Location Map
                          if (user.locationName.isNotEmpty &&
                              user.latitude != 0.0) ...[
                            verticalSpace(30),
                            LocationMapSection(
                              latitude: user.latitude,
                              longitude: user.longitude,
                              locationName: user.locationName,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  //
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
