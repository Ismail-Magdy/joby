import "package:flutter/material.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";
import "package:joby/core/widgets/custom_app_bar_with_no_leading.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import "package:joby/core/routes/routes.dart";
import "package:joby/core/helpers/extensions.dart";
import "../widgets/custom_settings_item.dart";

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      //
      appBar: CustomAppBarWithNoLeading(text: "Settings"),
      //
      body: Padding(
        padding: .symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
          children: [
            //
            CustomSettingsItem(
              icon: "assets/svgs/about-us.svg",
              label: "About Us",
              onTap: () => context.pushNamed(Routes.aboutUsScreen),
            ),
            //
            CustomSettingsItem(
              icon: "assets/svgs/advice.svg",
              label: "FeedBack?",
              onTap: () => context.pushNamed(Routes.adviceScreen),
            ),
            //
            CustomSettingsItem(
              isLogout: true,
              icon: "assets/svgs/logout.svg",
              label: "Logout",
              onTap: () async {
                final bool? confirmLogout = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: .circular(20.r),
                    ),
                    title: Text(
                      "Logout",
                      style: TextStyle(
                        fontFamily: "BrunoAceSC",
                        fontSize: 18.sp,
                        fontWeight: .bold,
                      ),
                    ),
                    content: Text(
                      "Are you sure you want to log out of your account?",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14.sp,
                            fontWeight: .w600,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: .circular(12.r),
                          ),
                          elevation: 0,
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 10.h,
                          ),
                        ),
                        child: Text(
                          "Logout",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: .w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirmLogout == true && context.mounted) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear();
                  await Supabase.instance.client.auth.signOut();
                  if (!context.mounted) return;
                  context.pushNamedAndRemoveUntil(
                    Routes.onBoardingScreen,
                    predicate: (route) => false,
                  );
                }
              },
            ),
            //
          ],
        ),
      ),
    );
  }
}
