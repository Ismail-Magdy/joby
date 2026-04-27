import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joby/core/themes/app_colors.dart';

class TwoAuthOptions extends StatelessWidget {
  const TwoAuthOptions({
    super.key,
    required this.isLogin,
    required this.onTapLogin,
    required this.onTapsignUp,
  });
  final bool isLogin;
  final void Function() onTapLogin;
  final void Function() onTapsignUp;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55.h,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: .circular(28.r),
      ),
      child: Row(
        children: [
          // Login Option
          Expanded(
            child: GestureDetector(
              onTap: onTapLogin,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: .all(4.r),
                decoration: BoxDecoration(
                  color: isLogin ? Colors.white : Colors.transparent,
                  borderRadius: .circular(24.r),
                  boxShadow: isLogin
                      ? [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ]
                      : [],
                ),
                alignment: .center,
                child: Text(
                  "Login",
                  style: TextStyle(
                    fontFamily: "BrunoAceSC",
                    fontSize: 16.sp,
                    fontWeight: isLogin ? .bold : .w500,
                    color: isLogin
                        ? AppColors.primaryColor
                        : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
            //
          ),
          // SignUp Option
          Expanded(
            child: GestureDetector(
              onTap: onTapsignUp,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: .all(4.r),
                decoration: BoxDecoration(
                  color: !isLogin ? Colors.white : Colors.transparent,
                  borderRadius: .circular(24.r),
                  boxShadow: !isLogin
                      ? [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ]
                      : [],
                ),
                alignment: .center,
                child: Text(
                  "Sign Up",
                  style: TextStyle(
                    fontFamily: "BrunoAceSC",
                    fontSize: 16.sp,
                    fontWeight: !isLogin ? .bold : .w500,
                    color: !isLogin
                        ? AppColors.primaryColor
                        : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          ),
          //
        ],
      ),
    );
    //
  }
}
