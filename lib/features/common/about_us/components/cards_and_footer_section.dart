import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ionicons/ionicons.dart';
import 'package:joby/core/helpers/spacing.dart';
import 'package:joby/core/themes/app_colors.dart';
import 'package:joby/features/common/about_us/components/footer_section.dart';
import 'package:joby/features/common/about_us/widgets/card_widget.dart';
import 'package:joby/features/common/about_us/widgets/custom_social_button.dart';
import 'package:joby/features/common/about_us/widgets/custom_tech_row.dart';
import 'package:url_launcher/url_launcher.dart';

class CardsAndFooterSection extends StatelessWidget {
  const CardsAndFooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //
        verticalSpace(24),
        // Mission Card
        CardWidget(
          icon: Ionicons.rocketOutline,
          title: "Our Mission",
          child: Text(
            "Joby Bridges The Gap Between Passionate Job Seekers and "
            "Forward Thinking Companies in Egypt and Beyond. We Believe "
            "The Right Talent and the Right Opportunity Should Always "
            "Find Each Other Fast, Smart, and Effortlessly",
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
          icon: Ionicons.personCircleOutline,
          title: "Meet The Creator",
          child: Row(
            children: [
              //
              CircleAvatar(
                radius: 28.r,
                backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
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
                      "Software Engineer",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    //
                    verticalSpace(8),
                    //
                    GestureDetector(
                      onTap: () =>
                          _launchUrl("mailto:ismailmagdy920@gmail.com"),
                      child: Row(
                        children: [
                          //
                          Icon(
                            Ionicons.mailOutline,
                            size: 12.sp,
                            color: AppColors.primaryColor,
                          ),
                          //
                          horizontalSpace(5),
                          //
                          Expanded(
                            child: Text(
                              "ismailmagdy920@gmail.com",
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: AppColors.primaryColor,
                              ),
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
          icon: Ionicons.codeSlashOutline,
          title: "Built With",
          child: Column(
            children: [
              //
              CustomTechRow(
                icon: Ionicons.phonePortraitOutline,
                name: "Flutter",
                description: "Cross Platform Mobile Framework by Google",
              ),
              //
              CustomTechRow(
                icon: Ionicons.serverOutline,
                name: "Supabase",
                description: "Open Source Backend & PostgreSQL Database",
              ),
              //
              CustomTechRow(
                icon: Ionicons.logoGithub,
                name: "GitHub",
                description: "Version Control and Code Hosting Platform",
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
          icon: Ionicons.shareSocialOutline,
          title: "Connect With Us",
          child: Wrap(
            alignment: .center,
            spacing: 20.w,
            runSpacing: 20.h,
            children: [
              // Facebook
              CustomSocialButton(
                icon: Ionicons.logoFacebook,
                label: "Facebook",
                color: const Color(0xFF1877F2),
                onTap: () =>
                    _launchUrl("https://www.facebook.com/share/1B4LsLAAdq/"),
              ),
              // Instagram
              CustomSocialButton(
                icon: Ionicons.logoInstagram,
                label: "Instagram",
                color: const Color(0xFFE4405F),
                onTap: () => _launchUrl(
                  "https://www.instagram.com/joby_app_?igsh=ZndvdHM4eTFzbXo1",
                ),
              ),
              // LinkedIn
              CustomSocialButton(
                icon: Ionicons.logoLinkedin,
                label: "LinkedIn",
                color: const Color(0xFF0077B5),
                onTap: () => _launchUrl(
                  "https://www.linkedin.com/company/joby-application/",
                ),
              ),
              // TikTok
              CustomSocialButton(
                icon: Ionicons.logoTiktok,
                label: "TikTok",
                color: Colors.black,
                onTap: () => _launchUrl(
                  "https://www.tiktok.com/@joby922?_r=1&_t=ZS-964FnlNpv1u",
                ),
              ),
              // WhatsApp
              CustomSocialButton(
                icon: Ionicons.logoWhatsapp,
                label: "WhatsApp",
                color: Colors.green,
                onTap: () => _launchUrl("https://wa.me/+201507090603"),
              ),
              // Site
              CustomSocialButton(
                icon: Ionicons.globeOutline,
                label: "Website",
                color: AppColors.primaryColor,
                onTap: () => _launchUrl("https://joby-site.vercel.app/"),
              ),
              // Email
              CustomSocialButton(
                icon: Ionicons.mailOutline,
                label: "Email",
                color: AppColors.primaryColor,
                onTap: () => _launchUrl("mailto:ismailmagdy920@gmail.com"),
              ),
              //
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
    );
  }

  ///
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: .externalApplication)) {
      debugPrint("AboutUsScreen: Could not launch $url");
    }
  }
}
