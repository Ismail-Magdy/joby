import "package:flutter/material.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";
import "package:joby/core/helpers/spacing.dart"; // اتأكد من المسار
import "package:joby/core/themes/app_colors.dart"; // اتأكد من المسار
import "package:supabase_flutter/supabase_flutter.dart"; // عشان الـ Logout
import "package:joby/core/routes/routes.dart"; // اتأكد من المسار

class UserSettingsScreen extends StatelessWidget {
  const UserSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        title: Text(
          "Settings",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
          children: [
            // 🔥 العناصر اللي في الرسمة (About us, Advice?, Logout) 🔥
            _buildSettingsItem(Icons.info_outline, "About Us", () {
              // TODO: صفحة عن التطبيق
            }),

            _buildSettingsItem(Icons.help_outline, "Advice?", () {
              // TODO: صفحة المساعدة أو النصائح
            }),

            const Spacer(), // يزق الـ Logout تحت
            // زرار الـ Logout
            _buildSettingsItem(Icons.logout, "Logout", () async {
              // عمل الـ Logout في سوبابيز
              await Supabase.instance.client.auth.signOut();
              if (!context.mounted) return;
              // التوجيه لشاشة الـ Auth
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(Routes.authScreen, (route) => false);
            }, isLogout: true),

            verticalSpace(100), // مسافة عشان الـ Bottom Nav Bar الزجاجي
          ],
        ),
      ),
    );
  }

  // Helper function لعمل عناصر السيتينجس
  Widget _buildSettingsItem(
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool isLogout = false,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isLogout ? Colors.red : AppColors.primaryColor,
          size: 24.sp,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 16.sp,
            color: isLogout ? Colors.red : Colors.black87,
            fontWeight: isLogout ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16.sp,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}
