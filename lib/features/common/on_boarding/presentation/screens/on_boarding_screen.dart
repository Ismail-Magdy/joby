import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:joby/core/helpers/spacing.dart';
import 'package:joby/core/themes/app_colors.dart';
import 'package:joby/features/common/on_boarding/manager/on_boarding_cubit.dart';
import 'package:joby/features/common/on_boarding/manager/on_boarding_state.dart';
import 'package:joby/features/common/on_boarding/presentation/widgets/user_type_card.dart';
import 'package:joby/core/routes/routes.dart';
import '../../../../../core/helpers/extensions.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: .symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: .center,
            children: [
              //
              SvgPicture.asset("assets/svgs/joby_logo.svg"),
              //
              verticalSpace(25),
              // WelCome
              Text(
                "Welcome to Joby",
                style: TextStyle(
                  fontSize: 26.sp,
                  fontWeight: .bold,
                  color: AppColors.primaryColor,
                  fontFamily: "BrunoAceSC",
                ),
              ),
              //
              verticalSpace(8),
              // Small Text
              Text(
                textAlign: .center,
                "Let's customize your experience. Tell us who you are.",
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              //
              verticalSpace(40),
              //
              // Select Type Of User
              BlocBuilder<OnBoardingCubit, OnBoardingState>(
                builder: (context, state) {
                  final cubit = context.read<OnBoardingCubit>();
                  return Column(
                    children: [
                      // Seeker Card
                      UserTypeCard(
                        title: "Job Seeker",
                        subtitle: "I am looking for my next career move.",
                        icon: FontAwesomeIcons.userTie,
                        isSelected: cubit.currentSelectedType == .seeker,
                        onTap: () => cubit.selectUserType(.seeker),
                      ),
                      //
                      verticalSpace(25),
                      // Company Card
                      UserTypeCard(
                        title: "Company",
                        subtitle: "I want to hire top talent.",
                        icon: FontAwesomeIcons.buildingUser,
                        isSelected: cubit.currentSelectedType == .company,
                        onTap: () => cubit.selectUserType(.company),
                      ),
                      //
                    ],
                  );
                },
              ),
              //
              const Spacer(),
              //
              // Continue Button
              BlocConsumer<OnBoardingCubit, OnBoardingState>(
                listener: (context, state) {
                  if (state is SaveUserTypeSuccess) {
                    // Navigate to Auth Screen after successful save
                    context.pushReplacementNamed(Routes.authScreen);
                  } else if (state is SaveUserTypeError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      // Snack Bar Error
                      SnackBar(
                        // Snack Bar Text Error
                        content: Text(
                          textAlign: .center,
                          state.message,
                          style: TextStyle(fontSize: 14.sp),
                        ),
                        //
                        backgroundColor: Colors.red,
                        behavior: .floating,
                        margin: .all(20.r),
                        shape: RoundedRectangleBorder(
                          borderRadius: .circular(10.r),
                        ),
                      ),
                      //
                    );
                  }
                },
                builder: (context, state) {
                  // Button
                  return SizedBox(
                    width: .infinity,
                    height: 55.h,
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<OnBoardingCubit>().saveSelection();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: .circular(14.r),
                        ),
                        elevation: 0,
                      ),
                      child: state is SaveUserTypeLoading
                          ? const CupertinoActivityIndicator(
                              color: Colors.white,
                            )
                          : Text(
                              "Continue",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: .bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  );
                  //
                },
              ),
              //
              verticalSpace(10),
              //
            ],
          ),
        ),
      ),
    );
  }
}
