import "dart:async";
import "package:flutter/material.dart";
import "package:joby/core/helpers/spacing.dart";
import "package:joby/features/common/auth/presentation/widgets/custom_google_button.dart";
import "package:joby/features/common/auth/presentation/widgets/forgot_password_widget.dart";
import "package:joby/features/common/auth/presentation/widgets/show_success_dialog.dart";
import "package:joby/features/common/auth/presentation/widgets/show_verification_dialog.dart";
import "package:joby/features/common/auth/presentation/widgets/two_auth_options.dart";
import "package:supabase_flutter/supabase_flutter.dart" as supabase;
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";
import "package:flutter_svg/svg.dart";
import "package:joby/core/routes/routes.dart";
import "package:joby/core/themes/app_colors.dart";
import "package:joby/features/common/auth/manager/auth_cubit.dart";
import "package:joby/features/common/auth/manager/auth_state.dart";
import "package:joby/features/common/auth/presentation/widgets/custom_divider.dart";
import "../../../../../core/helpers/extensions.dart";
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

  StreamSubscription<supabase.AuthState>? _authSubscription;
  bool _isAuthInProgress = false;

  ///
  @override
  void initState() {
    super.initState();
    _authSubscription = supabase.Supabase.instance.client.auth.onAuthStateChange
        .listen((data) {
          final supabase.AuthChangeEvent event = data.event;
          if (event == supabase.AuthChangeEvent.signedIn &&
              !_isAuthInProgress) {
            if (!mounted) return;
            // Success State
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return Dialog(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: .circular(16.r)),
                  child: ShowSuccessDialog(
                    onPressed: () {
                      supabase.Supabase.instance.client.auth.signOut();
                      context.pop();
                      setState(() => isLogin = true);
                    },
                  ),
                );
              },
            );
            //
          }
        });
  }

  //
  @override
  void dispose() {
    _authSubscription?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _submitForm(AuthCubit cubit) {
    if (_formKey.currentState!.validate()) {
      _isAuthInProgress = true;
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              //
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Center(
                    child: Text(
                      "Welcome ${state.user.name}",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontFamily: "BrunoAceSC",
                      ),
                    ),
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.all(20.r),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
              );
              //
              if (state.hasProfile) {
                if (state.userType == "company") {
                  context.pushReplacementNamed(Routes.companyHomeScreen);
                } else {
                  context.pushReplacementNamed(Routes.userRootScreen);
                }
              } else {
                if (state.userType == "company") {
                  context.pushReplacementNamed(Routes.companyHomeScreen);
                } else {
                  context.pushReplacementNamed(Routes.userInfoScreen);
                }
              }
            } else if (state is AuthSignUpRequiresVerification) {
              _isAuthInProgress = false;
              // Verification Dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return Dialog(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: .circular(16.r),
                    ),
                    child: ShowVerificationDialog(
                      onPressed: () {
                        context.pop();
                        setState(() => isLogin = true);
                      },
                    ),
                  );
                },
              );
              //
            } else if (state is AuthError) {
              _isAuthInProgress = false;
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
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.all(20.r),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
              );
              //
            }
          },
          //
          builder: (context, state) {
            final cubit = context.read<AuthCubit>();
            return SingleChildScrollView(
              padding: .symmetric(horizontal: 24.w, vertical: 30.h),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: .center,
                  children: [
                    //
                    SvgPicture.asset("assets/svgs/joby_logo.svg"),
                    //
                    verticalSpace(10),
                    //
                    Text(
                      "Go ahead and set up your account",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade600,
                        fontFamily: "BrunoAceSC",
                      ),
                    ),
                    //
                    verticalSpace(40),
                    // Two Auth Options
                    TwoAuthOptions(
                      isLogin: isLogin,
                      onTapLogin: () => setState(() => isLogin = true),
                      onTapsignUp: () => setState(() => isLogin = false),
                    ),
                    //
                    verticalSpace(30),
                    //
                    if (!isLogin) ...[
                      //
                      CustomTextFormField(
                        controller: _nameController,
                        hintText: "Full Name",
                        fieldType: .normal,
                        prefixIcon: Icons.person_outline,
                        validator: (val) =>
                            val!.isEmpty ? "Please enter your name" : null,
                      ),
                      //
                      verticalSpace(16),
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
                      // Forgot Password Logic & Widget
                      ForgotPasswordWidget(),
                    //
                    verticalSpace(isLogin ? 10 : 30),
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
                    verticalSpace(30),
                    // Custom Divider
                    CustomDivider(),
                    //
                    verticalSpace(25),
                    // Google Button
                    CustomGoogleButton(
                      onPressed: state is AuthLoading
                          ? null
                          : () {
                              _isAuthInProgress = true;
                              cubit.signInWithGoogle();
                            },
                    ),
                    //
                  ],
                ),
              ),
            );
          },
          //
        ),
      ),
    );
  }
}
