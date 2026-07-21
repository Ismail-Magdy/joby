import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joby/core/helpers/extensions.dart';
import 'package:joby/core/helpers/spacing.dart';
import 'package:joby/core/themes/app_colors.dart';
import 'package:joby/core/widgets/custom_app_bar.dart';
import 'package:joby/features/common/forgot_password/manager/forgot_password_cubit.dart';
import 'package:joby/features/common/forgot_password/manager/forgot_password_state.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      //
      appBar: CustomAppBar(text: "Forgot Password"),
      //
      body: SafeArea(
        child: BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
          listener: (context, state) {
            if (state is ForgotPasswordSuccess) {
              //
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    "Password reset link sent! Check your inbox or spam folder",
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  margin: .all(20.r),
                  shape: RoundedRectangleBorder(borderRadius: .circular(10.r)),
                ),
              );
              //
              context.pop();
              //
            } else if (state is ForgotPasswordError) {
              //
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  margin: .all(20.r),
                  shape: RoundedRectangleBorder(borderRadius: .circular(10.r)),
                ),
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: .symmetric(horizontal: 24.w, vertical: 20.h),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: .center,
                  children: [
                    //
                    Icon(
                      Icons.lock_reset_rounded,
                      size: 100.sp,
                      color: AppColors.primaryColor,
                    ),
                    //
                    verticalSpace(24),
                    //
                    Text(
                      "Reset Password",
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: .bold,
                        color: AppColors.primaryColor,
                        fontFamily: "BrunoAceSC",
                      ),
                    ),
                    //
                    verticalSpace(10),
                    //
                    Text(
                      "Enter the email associated with your account and we'll send an email with instructions to reset your password",
                      textAlign: .center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),
                    //
                    verticalSpace(40),
                    //
                    //
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: "Email Address",
                        prefixIcon: const Icon(Icons.email_outlined),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: .symmetric(
                          horizontal: 16.w,
                          vertical: 16.h,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: const BorderSide(
                            color: AppColors.primaryColor,
                            width: 1.5,
                          ),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return "Please enter your email";
                        }
                        if (!RegExp(
                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                        ).hasMatch(val.trim())) {
                          return "Please enter a valid email";
                        }
                        return null;
                      },
                    ),
                    //
                    verticalSpace(30),
                    //
                    //
                    SizedBox(
                      width: .infinity,
                      height: 55.h,
                      child: ElevatedButton(
                        onPressed: state is ForgotPasswordLoading
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  FocusScope.of(context).unfocus();

                                  context
                                      .read<ForgotPasswordCubit>()
                                      .sendResetEmail(
                                        _emailController.text.trim(),
                                      );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          elevation: 0,
                        ),
                        child: state is ForgotPasswordLoading
                            ? const CupertinoActivityIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                "Send Reset Link",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
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
// 218