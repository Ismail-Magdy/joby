import "package:flutter/material.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";
import "package:url_launcher/url_launcher.dart";
import "package:joby/core/helpers/spacing.dart";
import "package:joby/core/widgets/pdf_viewer_screen.dart";
import "package:joby/features/users/user_info/data/models/user_info_model.dart";
import "package:joby/features/users/home/presentation/widgets/custom_info_row.dart";
import "package:joby/features/users/home/presentation/widgets/cv_section.dart";
import "package:joby/features/users/home/presentation/widgets/location_map_section.dart";
import "package:joby/features/users/home/presentation/widgets/social_media_row.dart";
import "package:joby/features/users/home/presentation/widgets/total_points_container.dart";
import "package:joby/features/users/home/presentation/widgets/profile_header_delegate.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:joby/features/company/home/manager/company_home_cubit.dart";
import "package:joby/features/company/home/manager/company_home_state.dart";

class TalentDetailsScreen extends StatefulWidget {
  final UserInfoModel seeker;

  const TalentDetailsScreen({super.key, required this.seeker});

  @override
  State<TalentDetailsScreen> createState() => _TalentDetailsScreenState();
}

class _TalentDetailsScreenState extends State<TalentDetailsScreen> {
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
    }
    //
    else {
      String finalUrl = urlString.trim();
      if (!finalUrl.startsWith("http://") && !finalUrl.startsWith("https://")) {
        finalUrl = "https://$finalUrl";
      }
      url = Uri.parse(finalUrl);
    }
    //
    try {
      if (!await launchUrl(url, mode: .externalApplication)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              content: const Center(child: Text("Could not launch the link")),
              backgroundColor: Colors.red,
              margin: .all(20),
              shape: RoundedRectangleBorder(borderRadius: .circular(10)),
            ),
          );
        }
      }
    }
    //
    catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: const Center(child: Text("Invalid link format")),
            backgroundColor: Colors.red,
            margin: .all(20),
            shape: RoundedRectangleBorder(borderRadius: .circular(10)),
          ),
        );
      }
    }
    //
  }

  /// Open CV
  void _openCV(String urlString) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            PdfViewerScreen(pdfUrl: urlString, title: "Resume"),
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

  ///
  String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text
        .split(" ")
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(" ");
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.seeker;

    return Scaffold(
      backgroundColor: Colors.white,

      body: CustomScrollView(
        slivers: [
          //
          SliverPersistentHeader(
            pinned: true,
            delegate: ProfileHeaderDelegate(
              userId: user.id?.toString() ?? "",
              avatarUrl: user.avatarUrl,
              title: "Talent Profile",
              name: _toTitleCase(user.displayShortName),
              jobTitle: _toTitleCase(user.jobTitle),
              showBackButton: true,
              trailingAction: BlocBuilder<CompanyHomeCubit, CompanyHomeState>(
                builder: (context, state) {
                  bool isSaved = false;
                  if (state is CompanyHomeLoaded) {
                    isSaved = state.savedSeekerIds.contains(user.id.toString());
                  }
                  return IconButton(
                    icon: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      context.read<CompanyHomeCubit>().toggleBookmark(user.id.toString());
                    },
                  );
                },
              ),
            ),
          ),
          //
          SliverPadding(
            // Bottom Space
            padding: EdgeInsets.only(bottom: 50.h),
            //
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  //
                  verticalSpace(60),
                  // Name
                  Text(
                    _toTitleCase(user.displayShortName),
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
                    _toTitleCase(user.jobTitle),
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: Colors.grey.shade600,
                      fontWeight: .w500,
                    ),
                  ),
                  //
                  verticalSpace(15),
                  //
                  TotalPointsContainer(text: user.totalPoints.toString()),
                  //
                  verticalSpace(25),
                  // Info Row
                  SingleChildScrollView(
                    scrollDirection: .horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: CustomInfoRow(
                      levelText: _toTitleCase(user.level),
                      jobCategoryText: _toTitleCase(user.jobCategory),
                      typeOfWorkText: _toTitleCase(user.typeOfWork),
                    ),
                  ),
                  //
                  verticalSpace(50),
                  //
                  SocialMediaRow(
                    showLinkedin:
                        user.linkedin != null && user.linkedin!.isNotEmpty,
                    showGithub: user.github != null && user.github!.isNotEmpty,
                    showBehance:
                        user.behance != null && user.behance!.isNotEmpty,
                    whatsappTap: () {
                      if (user.whatsapp.isNotEmpty) {
                        _launchUrl(user.whatsapp, isPhone: true);
                      }
                    },
                    linkedinTap: () {
                      if (user.linkedin != null && user.linkedin!.isNotEmpty) {
                        _launchUrl(user.linkedin!);
                      }
                    },
                    githubTap: () {
                      if (user.github != null && user.github!.isNotEmpty) {
                        _launchUrl(user.github!);
                      }
                    },
                    behanceTap: () {
                      if (user.behance != null && user.behance!.isNotEmpty) {
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
                        verticalSpace(30),
                        if (user.cvUrl != null && user.cvUrl!.isNotEmpty)
                          CvSection(onTap: () => _openCV(user.cvUrl!)),
                      ],
                    ),
                  ),
                  //
                  if (user.locationName.isNotEmpty && user.latitude != 0.0) ...[
                    //
                    verticalSpace(30),
                    //
                    LocationMapSection(
                      latitude: user.latitude,
                      longitude: user.longitude,
                      locationName: user.locationName,
                    ),
                    //
                  ],
                  //
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
