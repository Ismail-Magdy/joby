import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ionicons/ionicons.dart';
import 'package:joby/core/helpers/spacing.dart';
import 'package:joby/core/themes/app_colors.dart';
import 'package:joby/features/users/about_us/presentation/widgets/card_widget.dart';
import 'package:joby/features/users/about_us/presentation/widgets/custom_social_button.dart';
import 'package:joby/features/users/about_us/presentation/widgets/custom_tech_row.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/about_header_delegate.dart';
import '../widgets/footer_section.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: .externalApplication)) {
      debugPrint("AboutUsScreen: Could not launch $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      //
      body: CustomScrollView(
        slivers: [
          // Collapsing Animated Header
          SliverPersistentHeader(
            pinned: true,
            delegate: AboutHeaderDelegate(version: "v 1.0.0"),
          ),
          // Content Cards
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  //
                  verticalSpace(24),
                  // Mission Card
                  CardWidget(
                    icon: Ionicons.rocket_outline,
                    title: "Our Mission",
                    child: Text(
                      'Joby bridges the gap between passionate job seekers and '
                      'forward thinking companies in Egypt and beyond. We believe '
                      'the right talent and the right opportunity should always '
                      'find each other fast, smart, and effortlessly.',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade700,
                        height: 1.65,
                      ),
                    ),
                  ),
                  //
                  verticalSpace(16),
                  // Creator Card
                  CardWidget(
                    icon: Ionicons.person_circle_outline,
                    title: "Meet the Creator",
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28.r,
                          backgroundColor: AppColors.primaryColor.withValues(
                            alpha: 0.1,
                          ),
                          child: Text(
                            "IM",
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontWeight: .bold,
                              fontSize: 18.sp,
                            ),
                          ),
                        ),
                        //
                        horizontalSpace(16),
                        //
                        Expanded(
                          child: Column(
                            crossAxisAlignment: .start,
                            children: [
                              // Name & Title
                              Text(
                                "Ismail Magdy",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: .bold,
                                  color: Colors.black87,
                                ),
                              ),
                              //
                              verticalSpace(3),
                              //
                              Text(
                                "Software Engineer & Flutter Developer",
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              //
                              verticalSpace(8),
                              //
                              GestureDetector(
                                onTap: () => _launchUrl(
                                  "mailto:ismailmagdy920@gmail.com",
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Ionicons.mail_outline,
                                      size: 14.sp,
                                      color: AppColors.primaryColor,
                                    ),
                                    //
                                    horizontalSpace(5),
                                    //
                                    Text(
                                      "ismailmagdy920@gmail.com",
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                    //
                                  ],
                                ),
                              ),
                              //
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  //
                  verticalSpace(16),
                  //
                  // Tech Stack Card
                  CardWidget(
                    icon: Ionicons.code_slash_outline,
                    title: "Built With",
                    child: Column(
                      children: [
                        //
                        CustomTechRow(
                          icon: Ionicons.phone_portrait_outline,
                          name: "Flutter",
                          description:
                              "Cross platform mobile framework by Google",
                        ),
                        //
                        CustomTechRow(
                          icon: Ionicons.server_outline,
                          name: "Supabase",
                          description:
                              "Open source backend & PostgreSQL database",
                        ),
                        //
                        CustomTechRow(
                          icon: Ionicons.logo_github,
                          name: "GitHub",
                          description:
                              "Version control and code hosting platform",
                        ),
                        //
                      ],
                    ),
                  ),
                  //
                  verticalSpace(16),
                  //
                  // Connect Card
                  CardWidget(
                    icon: Ionicons.share_social_outline,
                    title: "Connect With Us",
                    child: Wrap(
                      alignment: .center,
                      spacing: 20.w,
                      runSpacing: 20.h,
                      children: [
                        // Facebook
                        CustomSocialButton(
                          icon: Ionicons.logo_facebook,
                          label: "Facebook",
                          color: const Color(0xFF1877F2),
                          onTap: () => _launchUrl(
                            "https://www.facebook.com/share/1B4LsLAAdq/",
                          ),
                        ),
                        // Instagram
                        CustomSocialButton(
                          icon: Ionicons.logo_instagram,
                          label: "Instagram",
                          color: const Color(0xFFE4405F),
                          onTap: () => _launchUrl(
                            "https://www.instagram.com/joby_app_?igsh=ZndvdHM4eTFzbXo1",
                          ),
                        ),
                        // LinkedIn
                        CustomSocialButton(
                          icon: Ionicons.logo_linkedin,
                          label: "LinkedIn",
                          color: const Color(0xFF0077B5),
                          onTap: () => _launchUrl(
                            "https://www.linkedin.com/company/joby-application/",
                          ),
                        ),
                        // TikTok
                        CustomSocialButton(
                          icon: Ionicons.logo_tiktok,
                          label: "TikTok",
                          color: Colors.black,
                          onTap: () => _launchUrl(
                            "https://www.tiktok.com/@joby922?_r=1&_t=ZS-964FnlNpv1u",
                          ),
                        ),
                        // WhatsApp
                        CustomSocialButton(
                          icon: Ionicons.logo_whatsapp,
                          label: "WhatsApp",
                          color: Colors.green,
                          onTap: () =>
                              _launchUrl("https://wa.me/+201507090603"),
                        ),
                        // Telegram
                        CustomSocialButton(
                          icon: Icons.telegram,
                          label: "Telegram",
                          color: const Color(0xFF0088cc),
                          onTap: () =>
                              _launchUrl("https://t.me/+Ly0NuI9eqhgxNTg0"),
                        ),
                        // Site
                        CustomSocialButton(
                          icon: Ionicons.globe_outline,
                          label: "Website",
                          color: AppColors.primaryColor,
                          onTap: () =>
                              _launchUrl("https://joby-site.vercel.app/"),
                        ),
                        // Email
                        CustomSocialButton(
                          icon: Ionicons.mail_outline,
                          label: "Email",
                          color: AppColors.primaryColor,
                          onTap: () =>
                              _launchUrl("mailto:ismailmagdy920@gmail.com"),
                        ),
                      ],
                    ),
                  ),
                  //
                  verticalSpace(40),
                  // Footer
                  FooterSection(),
                  //
                  verticalSpace(30),
                  //
                ],
              ),
            ),
          ),
          //
        ],
      ),
    );
  }
}
