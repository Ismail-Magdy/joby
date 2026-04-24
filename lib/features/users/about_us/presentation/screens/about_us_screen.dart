import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ionicons/ionicons.dart';
import 'package:joby/core/helpers/spacing.dart';
import 'package:joby/core/themes/app_colors.dart';
import 'package:joby/features/users/about_us/presentation/widgets/card_widget.dart';
import 'package:joby/features/users/about_us/presentation/widgets/custom_social_button.dart';
import 'package:joby/features/users/about_us/presentation/widgets/custom_tech_row.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/custom_header.dart';
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
      // App Bar
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "About Us",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20.sp,
            fontWeight: .bold,
            fontFamily: "BrunoAceSC",
          ),
        ),
      ),
      //
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Gradient Header
            CustomHeader(),
            //  Content Cards
            Padding(
              padding: .symmetric(horizontal: 20.w),
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
                                "Flutter Developer & Software Engineer",
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
                              "Cross-platform mobile framework by Google",
                        ),
                        //
                        CustomTechRow(
                          icon: Ionicons.server_outline,
                          name: "Supabase",
                          description:
                              "Open-source backend & PostgreSQL database",
                        ),
                        //
                        CustomTechRow(
                          icon: Ionicons.sparkles_outline,
                          name: "Google Gemini AI",
                          description: "AI-powered career coaching assistant",
                          isLast: true,
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
                    child: Row(
                      mainAxisAlignment: .spaceEvenly,
                      children: [
                        //
                        CustomSocialButton(
                          icon: Ionicons.logo_github,
                          label: "GitHub",
                          color: const Color(0xFF333333),
                          onTap: () =>
                              _launchUrl("https://github.com/Ismail-Magdy"),
                        ),
                        //
                        CustomSocialButton(
                          icon: Ionicons.logo_linkedin,
                          label: "LinkedIn",
                          color: const Color(0xFF0077B5),
                          onTap: () => _launchUrl(
                            "https://linkedin.com/in/ismailmagdy021",
                          ),
                        ),
                        //
                        CustomSocialButton(
                          icon: Ionicons.mail_outline,
                          label: "Email",
                          color: AppColors.primaryColor,
                          onTap: () =>
                              _launchUrl("mailto:ismailmagdy920@gmail.com"),
                        ),
                        //
                        //
                        CustomSocialButton(
                          icon: Ionicons.logo_whatsapp,
                          label: "WhatsApp",
                          color: Colors.green,
                          onTap: () =>
                              _launchUrl("https://wa.me/+201206607906"),
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
              ),
            ),
            //
          ],
        ),
      ),
    );
  }
}
