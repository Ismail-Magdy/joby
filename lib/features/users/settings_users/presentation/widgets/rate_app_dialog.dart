import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joby/core/helpers/extensions.dart';
import 'package:joby/core/helpers/spacing.dart';
import 'package:joby/core/themes/app_colors.dart';
import 'package:joby/core/themes/app_text_styles.dart';
import 'package:joby/core/widgets/custom_feedback_dialog.dart';
import '../../data/models/app_rating_model.dart';
import '../../manager/settings_users_cubit.dart';
import '../../manager/settings_users_state.dart';

class RateAppDialog extends StatefulWidget {
  final AppRatingModel? initialRating;

  const RateAppDialog({super.key, this.initialRating});

  @override
  State<RateAppDialog> createState() => _RateAppDialogState();
}

class _RateAppDialogState extends State<RateAppDialog> {
  late int _selectedStars;
  late final TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _selectedStars = widget.initialRating?.rating ?? 0;
    _commentController = TextEditingController(
      text: widget.initialRating?.comment ?? '',
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsUsersCubit, SettingsUsersState>(
      listenWhen: (previous, current) =>
          current.ratingSubmitSuccess != previous.ratingSubmitSuccess ||
          current.ratingError != previous.ratingError,
      listener: (context, state) {
        if (state.ratingSubmitSuccess) {
          Navigator.of(context).pop();
          CustomFeedbackDialog.showSuccess(
            context,
            title: 'Thank You',
            message: 'Your Rating Has Been Saved Successfully',
          );
        } else if (state.ratingError != null) {
          CustomFeedbackDialog.showError(
            context,
            title: 'Rating Failed',
            message: state.ratingError!,
          );
        }
      },
      builder: (context, state) {
        return Dialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(borderRadius: .circular(24.r)),
          child: Padding(
            padding: .all(24.r),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: .min,
                children: [
                  Container(
                    width: 56.w,
                    height: 56.w,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.14),
                      shape: .circle,
                    ),
                    child: Icon(
                      Icons.star_rounded,
                      color: AppColors.primaryColor,
                      size: 32.sp,
                    ),
                  ),
                  verticalSpace(14),
                  Text(
                    "Rate JOBY",
                    style: AppTextStyles.dialogTitle(AppColors.textPrimary),
                  ),
                  verticalSpace(6),
                  Text(
                    "Tap a Star To Rate Your Experience",
                    textAlign: .center,
                    style: AppTextStyles.dialogMessage,
                  ),
                  verticalSpace(15),
                  Row(
                    mainAxisAlignment: .center,
                    children: List.generate(5, (index) {
                      final starValue = index + 1;
                      final isSelected = starValue <= _selectedStars;
                      return GestureDetector(
                        onTap: state.isSubmittingRating
                            ? null
                            : () => setState(() => _selectedStars = starValue),
                        child: Padding(
                          padding: .symmetric(horizontal: 4.w),
                          child: AnimatedScale(
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeOutBack,
                            scale: isSelected ? 1.15 : 1.0,
                            child: Icon(
                              isSelected
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              color: isSelected
                                  ? Colors.amber.shade600
                                  : Colors.grey.shade400,
                              size: 36.sp,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  verticalSpace(18),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: state.isSubmittingRating
                              ? null
                              : () => context.pop(),
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: .w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      horizontalSpace(10),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed:
                              (_selectedStars == 0 || state.isSubmittingRating)
                              ? null
                              : () {
                                  context
                                      .read<SettingsUsersCubit>()
                                      .submitRating(
                                        rating: _selectedStars,
                                        comment: _commentController.text,
                                      );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            disabledBackgroundColor: Colors.grey.shade300,
                            shape: RoundedRectangleBorder(
                              borderRadius: .circular(14.r),
                            ),
                            padding: .symmetric(vertical: 12.h),
                            elevation: 0,
                          ),
                          child: state.isSubmittingRating
                              ? const CupertinoActivityIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  "Submit Rating",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: .w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
// 231
