import "package:flutter/material.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";
import "package:joby/core/helpers/spacing.dart";
import "package:joby/core/themes/app_colors.dart";
import "package:supabase_flutter/supabase_flutter.dart";

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              alignment: .center,
              children: [
                CustomPaint(
                  size: Size(.infinity, 160.h),
                  painter: CurvePainter(),
                ),
                Positioned(
                  top: 60.h,
                  left: 20.w,
                  right: 20.w,
                  child: Row(
                    mainAxisAlignment: .spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: Icon(
                          Icons.business_center_outlined,
                          color: Colors.white,
                          size: 26.sp,
                        ),
                      ),
                      Text(
                        "My Profile",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Icon(
                          Icons.edit_outlined,
                          color: Colors.white,
                          size: 26.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            verticalSpace(30),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryColor,
                        width: 3,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 65.r,
                      backgroundColor: Colors.grey.shade100,
                      child: Icon(
                        Icons.person,
                        size: 65.sp,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
                  verticalSpace(20),
                  Text(
                    user?.userMetadata?["name"] ?? "Ismail Magdy",
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  verticalSpace(5),
                  Text(
                    "Flutter Developer",
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  verticalSpace(30),

                  _buildProfileDetailItem(
                    Icons.leaderboard_outlined,
                    "Level",
                    "Senior",
                  ),
                  _buildProfileDetailItem(
                    Icons.business_center_outlined,
                    "Work Type",
                    "Remote",
                  ),
                  _buildProfileDetailItem(
                    Icons.phone_android_outlined,
                    "WhatsApp",
                    "01099166668",
                  ),
                  _buildProfileDetailItem(
                    Icons.link_outlined,
                    "LinkedIn",
                    "/ismail-magdy",
                  ),
                  _buildProfileDetailItem(
                    Icons.code_outlined,
                    "GitHub",
                    "/ismail-magdy",
                  ),

                  verticalSpace(20),

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(15.r),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.description_outlined,
                              color: AppColors.primaryColor,
                              size: 30.sp,
                            ),
                            horizontalSpace(15),
                            Text(
                              "My Resume.pdf",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.download_for_offline_outlined,
                          color: Colors.grey,
                          size: 26.sp,
                        ),
                      ],
                    ),
                  ),

                  verticalSpace(100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade500, size: 22.sp),
          horizontalSpace(15),
          Text(
            "$label:",
            style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade700),
          ),
          horizontalSpace(10),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class CurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = AppColors.primaryColor; // اللون الأزرق بتاعك
    paint.style = PaintingStyle.fill;

    var path = Path();

    // رسم المنحنى
    path.moveTo(0, size.height * 0.75);
    path.quadraticBezierTo(
      size.width / 2,
      size.height * 1.1,
      size.width,
      size.height * 0.75,
    );
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
