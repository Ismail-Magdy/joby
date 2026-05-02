import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joby/core/helpers/spacing.dart';
import 'package:joby/core/themes/app_colors.dart';

class CustomTwoButtonsRow extends StatelessWidget {
  const CustomTwoButtonsRow({
    super.key,
    required this.onPressed,
    required this.child,
    required this.currentStep,
    required this.onStepCancelpressed,
  });
  final void Function()? onPressed;
  final Widget? child;
  final int currentStep;
  final void Function()? onStepCancelpressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: .only(top: 20.h),
      child: Row(
        children: [
          //
          Expanded(
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: .symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(borderRadius: .circular(8.r)),
              ),
              child: child,
            ),
          ),
          //
          if (currentStep != 0) ...[
            //
            horizontalSpace(12),
            //
            Expanded(
              child: OutlinedButton(
                onPressed: onStepCancelpressed,
                style: OutlinedButton.styleFrom(
                  padding: .symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(borderRadius: .circular(8.r)),
                ),
                child: Text(
                  "Back",
                  style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                ),
              ),
            ),
            //
          ],
        ],
      ),
    );
    //
  }
}
