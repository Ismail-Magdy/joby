import "package:flutter/material.dart";
import "package:joby/core/widgets/home_shimmer_loading.dart";
import "package:joby/features/users/home/presentation/components/home_info_row.dart";
import "package:joby/features/users/home/presentation/components/cv_section.dart";
import "package:joby/features/users/home/presentation/widgets/location_map_section.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";
import "package:joby/core/helpers/extensions.dart";
import "package:joby/core/routes/routes.dart";
import "package:joby/core/widgets/error_screen.dart";
import "package:joby/core/widgets/custom_feedback_dialog.dart";
import "package:joby/features/users/home/presentation/components/social_media_row.dart";
import "package:joby/features/users/home/presentation/widgets/home_total_points_container.dart";
import "package:joby/features/users/points/manager/points_cubit.dart";
import "package:joby/features/users/points/manager/points_state.dart";
import "package:joby/features/users/points/presentation/widgets/points_celebration_dialog.dart";
import "package:url_launcher/url_launcher.dart";
import "package:joby/core/helpers/spacing.dart";
import "../../manager/user_home_cubit.dart";
import "../../manager/user_home_state.dart";
import '../widgets/profile_header_delegate.dart';
import "package:joby/features/users/user_info/presentation/screens/location_picker_screen.dart";
import "package:joby/features/users/user_info/data/models/location_picker_result.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import "package:joby/core/widgets/pdf_viewer_screen.dart";
import "package:joby/features/users/games/presentation/widgets/games_entry_banner_card.dart";

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  bool _isAvatarLoading = false;
  String? _loadedAvatarUrl;

  @override
  void initState() {
    super.initState();
    context.read<UserHomeCubit>().getUserData();
  }

  Future<void> _editLocation(
    double currentLat,
    double currentLng,
    String currentLocationName,
  ) async {
    final result = await Navigator.of(context).push<LocationPickerResult>(
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(
          initialLatitude: currentLat,
          initialLongitude: currentLng,
          initialLocationName: currentLocationName,
        ),
      ),
    );

    if (result != null && mounted) {
      final error = await context.read<UserHomeCubit>().updateUserLocation(
        latitude: result.latitude,
        longitude: result.longitude,
        locationName: result.locationName,
      );

      if (mounted) {
        if (error != null) {
          CustomFeedbackDialog.showError(
            context,
            title: "Location Error",
            message: error,
          );
        } else {
          CustomFeedbackDialog.showSuccess(
            context,
            title: "Success",
            message: "Location updated successfully",
          );
        }
      }
    }
  }

  ///
  Future<void> _launchUrl(String urlString, {bool isPhone = false}) async {
    Uri url;

    if (isPhone) {
      bool hasCountryCode = urlString.trim().startsWith("+");
      String cleanedPhone = urlString.replaceAll(RegExp(r"\D"), "");

      if (!hasCountryCode) {
        if (cleanedPhone.startsWith("01") && cleanedPhone.length == 11) {
          cleanedPhone = "20${cleanedPhone.substring(1)}";
        } else if (!cleanedPhone.startsWith("20")) {
          cleanedPhone = "20$cleanedPhone";
        }
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
          CustomFeedbackDialog.showError(
            context,
            title: "Link Error",
            message: "Could Not Launch The Link",
          );
        }
      }
    } catch (e) {
      if (mounted) {
        CustomFeedbackDialog.showError(
          context,
          title: "Invalid Link",
          message: "Invalid link format",
        );
      }
    }
  }

  ///
  void _openCV(String urlString) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            PdfViewerScreen(pdfUrl: urlString, title: "My Resume"),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }

  //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: BlocListener<PointsCubit, PointsState>(
        //
        listener: (context, state) {
          // Points Claim Celebration
          if (state is PointsClaimCelebration) {
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
          }
          //
          // Points Claim Error
          else if (state is PointsClaimError) {
            CustomFeedbackDialog.showError(
              context,
              title: "Points Claim Error",
              message: "RPC Error: ${state.message}",
            );
          }
          //
          // Points Already Claimed
          else if (state is PointsClaimAlreadyClaimed) {
            CustomFeedbackDialog.showInfo(
              context,
              title: "Already Claimed",
              message: "Points Already claimed",
            );
          }
          //
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
              return ErrorScreen();
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
                      userId:
                          Supabase.instance.client.auth.currentUser?.id ?? "",
                      avatarUrl: user.avatarUrl,
                      title: "My Profile",
                      name: user.displayShortName,
                      jobTitle: user.jobTitle,
                      onManagerTap: () =>
                          context.pushNamed(Routes.companyViewScreen),
                      onEditTap: () async {
                        final result = await context.pushNamed(
                          Routes.editProfileScreen,
                          arguments: user,
                        );
                        if (result == true && mounted) {
                          () => context.read<UserHomeCubit>().getUserData();
                        }
                      },
                    ),
                  ),
                  //
                  // Body content
                  SliverPadding(
                    padding: .only(bottom: 140.h),
                    sliver: SliverToBoxAdapter(
                      //
                      child: Column(
                        children: [
                          //
                          verticalSpace(70),
                          // Name
                          Text(
                            user.displayShortName.toTitleCase(),
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: .bold,
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
                              fontWeight: .w500,
                            ),
                          ),
                          //
                          verticalSpace(15),
                          // Total Points
                          HomeTotalPointsContainer(
                            text: user.totalPoints.toString(),
                          ),
                          //
                          verticalSpace(15),
                          const GamesEntryBannerCard(),
                          //
                          verticalSpace(25),
                          // Level, Job Category, & Work Type
                          SingleChildScrollView(
                            scrollDirection: .horizontal,
                            physics: BouncingScrollPhysics(),
                            child: HomeInfoRow(
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
                                  CvSection(onTap: () => _openCV(user.cvUrl!)),
                                //
                              ],
                            ),
                          ),
                          //
                          // Location Map
                          if (user.locationName.isNotEmpty &&
                              user.latitude != 0.0) ...[
                            //
                            verticalSpace(30),
                            //
                            LocationMapSection(
                              latitude: user.latitude,
                              longitude: user.longitude,
                              locationName: user.locationName,
                              onEditTap: () => _editLocation(
                                user.latitude,
                                user.longitude,
                                user.locationName,
                              ),
                            ),
                            //
                          ],
                        ],
                      ),
                      //
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
// 444
