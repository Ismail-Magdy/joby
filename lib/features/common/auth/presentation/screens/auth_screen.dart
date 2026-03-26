import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";
import "package:flutter_svg/svg.dart";
import "package:font_awesome_flutter/font_awesome_flutter.dart";
import "package:joby/core/helpers/extensions.dart";
import "package:joby/core/routes/routes.dart";
import "package:joby/core/themes/app_colors.dart";
import "package:joby/features/common/auth/manager/auth_cubit.dart";
import "package:joby/features/common/auth/manager/auth_state.dart";
import "package:joby/features/common/auth/presentation/widgets/custom_divider.dart";

import "../../../../../core/widgets/custom_text_field.dart";

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _submitForm(AuthCubit cubit) {
    if (_formKey.currentState!.validate()) {
      if (isLogin) {
        cubit.signInWithEmail(_emailController.text, _passwordController.text);
      } else {
        cubit.signUpWithEmail(
          _emailController.text,
          _passwordController.text,
          _nameController.text,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              //
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Center(
                    child: Text(
                      "Welcome ${state.user.name}!",
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ),
                  backgroundColor: Colors.green,
                  behavior: .floating,
                  margin: .all(20.r),
                  shape: RoundedRectangleBorder(borderRadius: .circular(10.r)),
                ),
              );
              //
              if (state.hasProfile) {
                if (state.userType == "company") {
                  context.pushReplacementNamed(Routes.companyHomeScreen);
                } else {
                  context.pushReplacementNamed(Routes.userHomeScreen);
                }
              } else {
                if (state.userType == "company") {
                  // TODO:  Company HomeScreen
                  context.pushReplacementNamed(Routes.companyHomeScreen);
                } else {
                  context.pushReplacementNamed(Routes.userInfoScreen);
                }
              }
            } else if (state is AuthError) {
              //
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Center(
                    child: Text(
                      state.message,
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ),
                  backgroundColor: Colors.red,
                  behavior: .floating,
                  margin: .all(20.r),
                  shape: RoundedRectangleBorder(borderRadius: .circular(10.r)),
                ),
              );
              //
            }
          },
          builder: (context, state) {
            final cubit = context.read<AuthCubit>();
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 30.h),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: .center,
                  children: [
                    //
                    SvgPicture.asset("assets/svgs/joby_logo.svg"),
                    //
                    SizedBox(height: 10.h),
                    //
                    Text(
                      "Go ahead and set up your account",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    //
                    SizedBox(height: 40.h),
                    // Two Auth Options
                    Container(
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
                              onTap: () => setState(() => isLogin = true),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: .all(4.r),
                                decoration: BoxDecoration(
                                  color: isLogin
                                      ? Colors.white
                                      : Colors.transparent,
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
                              onTap: () => setState(() => isLogin = false),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: .all(4.r),
                                decoration: BoxDecoration(
                                  color: !isLogin
                                      ? Colors.white
                                      : Colors.transparent,
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
                    ),
                    //
                    SizedBox(height: 30.h),
                    //
                    if (!isLogin) ...[
                      CustomTextFormField(
                        controller: _nameController,
                        hintText: "Full Name",
                        fieldType: .normal,
                        prefixIcon: Icons.person_outline,
                        validator: (val) =>
                            val!.isEmpty ? "Please enter your name" : null,
                      ),
                      //
                      SizedBox(height: 16.h),
                      //
                    ],
                    // Email
                    CustomTextFormField(
                      controller: _emailController,
                      hintText: "Email Address",
                      fieldType: .email,
                      prefixIcon: Icons.email_outlined,
                    ),
                    //
                    SizedBox(height: 16.h),
                    // Password
                    CustomTextFormField(
                      controller: _passwordController,
                      hintText: "Password",
                      fieldType: .password,
                      prefixIcon: Icons.lock_outline,
                    ),
                    //
                    SizedBox(height: 10.h),
                    //
                    if (isLogin)
                      Align(
                        alignment: .centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 13.sp,
                            ),
                          ),
                        ),
                      ),
                    //
                    SizedBox(height: isLogin ? 10.h : 30.h),
                    // Button
                    SizedBox(
                      width: double.infinity,
                      height: 55.h,
                      child: ElevatedButton(
                        onPressed: state is AuthLoading
                            ? null
                            : () => _submitForm(cubit),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: .circular(14.r),
                          ),
                          elevation: 0,
                        ),
                        child: state is AuthLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                isLogin ? "Login" : "Sign Up",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: .bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    //
                    SizedBox(height: 30.h),
                    // Custom Divider
                    CustomDivider(),
                    //
                    SizedBox(height: 25.h),
                    // Google Button
                    SizedBox(
                      width: .infinity,
                      height: 55.h,
                      child: OutlinedButton.icon(
                        onPressed: state is AuthLoading
                            ? null
                            : () => cubit.signInWithGoogle(),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: .circular(14.r),
                          ),
                        ),
                        icon: const FaIcon(
                          FontAwesomeIcons.google,
                          color: Colors.black,
                          size: 20,
                        ),
                        label: Text(
                          "Google",
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: .w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    //
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
