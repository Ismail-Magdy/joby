import "package:flutter/material.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import "package:joby/core/routes/routes.dart";
import "package:joby/core/helpers/extensions.dart";
import "../widgets/custom_settings_item.dart";

class UserSettingsScreen extends StatelessWidget {
  const UserSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      //
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        title: Text(
          "Settings",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: .bold,
            fontSize: 20.sp,
            fontFamily: "BrunoAceSC",
          ),
        ),
        centerTitle: true,
      ),
      //
      body: Padding(
        padding: .symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
          children: [
            CustomSettingsItem(
              icon: "assets/svgs/about-us.svg",
              label: "About Us",
              onTap: () => context.pushNamed(Routes.aboutUsScreen),
            ),
            CustomSettingsItem(
              icon: "assets/svgs/advice.svg",
              label: "Advice?",
              onTap: () => context.pushNamed(Routes.adviceScreen),
            ),
            CustomSettingsItem(
              isLogout: true,
              icon: "assets/svgs/logout.svg",
              label: "Logout",
              onTap: () async {
                await Supabase.instance.client.auth.signOut();
                if (!context.mounted) return;
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil(Routes.authScreen, (route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }
}
