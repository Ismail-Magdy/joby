import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:joby/core/helpers/spacing.dart';
import 'package:joby/core/themes/app_colors.dart';
import 'package:joby/features/common/auth/manager/auth_cubit.dart';
import 'package:joby/features/common/auth/manager/auth_state.dart';

import '../../../../../core/widgets/custom_text_field.dart';

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
              // Snccess
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    textAlign: .center,
                    "Welcome ${state.user.name}!",
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  backgroundColor: Colors.green,
                  behavior: .floating,
                  margin: .all(20.r),
                  shape: RoundedRectangleBorder(borderRadius: .circular(10.r)),
                ),
              );
              //
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                // Error
                SnackBar(
                  content: Text(
                    textAlign: .center,
                    state.message,
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  backgroundColor: Colors.red,
                  behavior: .floating,
                  margin: .all(20.r),
                  shape: RoundedRectangleBorder(borderRadius: .circular(10.r)),
                ),
              );
            }
          },
          builder: (context, state) {
            final cubit = context.read<AuthCubit>();
            return SingleChildScrollView(
              padding: .symmetric(horizontal: 24.w, vertical: 30.h),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: .center,
                  children: [
                    // Logo
                    SvgPicture.asset("assets/svgs/joby_logo.svg"),
                    //
                    verticalSpace(10),
                    // Small Text
                    Text(
                      "Go ahead and set up your account",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    //
                    verticalSpace(40),
                    // Tab Bar Button
                    Container(
                      height: 55.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: .circular(28.r),
                      ),
                      child: Row(
                        children: [
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
                                  borderRadius: BorderRadius.circular(24.r),
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
                          ),
                          //
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
                                    fontWeight: !isLogin
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: !isLogin
                                        ? AppColors.primaryColor
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    //
                    verticalSpace(30),
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
                      verticalSpace(16),
                    ],
                    // Email
                    CustomTextFormField(
                      controller: _emailController,
                      hintText: "Email Address",
                      fieldType: .email,
                      prefixIcon: Icons.email_outlined,
                    ),
                    //
                    verticalSpace(16),
                    // Password
                    CustomTextFormField(
                      controller: _passwordController,
                      hintText: "Password",
                      fieldType: .password,
                      prefixIcon: Icons.lock_outline,
                    ),
                    //
                    verticalSpace(10),
                    //
                    if (isLogin)
                      // Forgot Password
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
                    verticalSpace(isLogin ? 10 : 30),
                    // Button
                    SizedBox(
                      width: .infinity,
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
                    verticalSpace(30),
                    // Divider
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: Colors.grey.shade300,
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: .symmetric(horizontal: 10.w),
                          child: Text(
                            "Or continue with",
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 13.sp,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Colors.grey.shade300,
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),
                    //
                    verticalSpace(25),
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
