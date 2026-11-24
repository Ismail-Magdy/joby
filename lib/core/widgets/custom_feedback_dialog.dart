import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joby/core/helpers/extensions.dart';
import 'package:joby/core/helpers/spacing.dart';
import 'package:joby/core/themes/app_colors.dart';
import 'package:joby/core/themes/app_text_styles.dart';

class CustomFeedbackDialog extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String message;
  final VoidCallback? onFinish;
  final Duration duration;

  const CustomFeedbackDialog({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
    this.onFinish,
    this.duration = const Duration(milliseconds: 2500),
  });

  /// Displays a success feedback dialog.
  static Future<void> showSuccess(
    BuildContext context, {
    required String message,
    String title = "Success",
    VoidCallback? onFinish,
    Duration duration = const Duration(milliseconds: 2500),
  }) {
    return show(
      context,
      icon: Icons.check_circle_outline_rounded,
      color: AppColors.success,
      title: title,
      message: message,
      onFinish: onFinish,
      duration: duration,
    );
  }

  /// Displays an error feedback dialog.
  static Future<void> showError(
    BuildContext context, {
    required String message,
    String title = "Error",
    VoidCallback? onFinish,
    Duration duration = const Duration(milliseconds: 2500),
  }) {
    return show(
      context,
      icon: Icons.error_outline_rounded,
      color: AppColors.error,
      title: title,
      message: message,
      onFinish: onFinish,
      duration: duration,
    );
  }

  /// Displays a warning feedback dialog.
  static Future<void> showWarning(
    BuildContext context, {
    required String message,
    String title = "Warning",
    VoidCallback? onFinish,
    Duration duration = const Duration(milliseconds: 2500),
  }) {
    return show(
      context,
      icon: Icons.warning_amber_rounded,
      color: AppColors.warning,
      title: title,
      message: message,
      onFinish: onFinish,
      duration: duration,
    );
  }

  /// Displays an info feedback dialog.
  static Future<void> showInfo(
    BuildContext context, {
    required String message,
    String title = "Notice",
    VoidCallback? onFinish,
    Duration duration = const Duration(milliseconds: 2500),
  }) {
    return show(
      context,
      icon: Icons.info_outline_rounded,
      color: AppColors.info,
      title: title,
      message: message,
      onFinish: onFinish,
      duration: duration,
    );
  }

  /// Displays a custom feedback dialog using a smooth scale & fade transition.
  static Future<void> show(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String message,
    VoidCallback? onFinish,
    Duration duration = const Duration(milliseconds: 2500),
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "Feedback",
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return CustomFeedbackDialog(
          icon: icon,
          color: color,
          title: title,
          message: message,
          onFinish: onFinish,
          duration: duration,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return Transform.scale(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          ).value,
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }

  @override
  State<CustomFeedbackDialog> createState() => _CustomFeedbackDialogState();
}

class _CustomFeedbackDialogState extends State<CustomFeedbackDialog> {
  bool _hasFinished = false;

  void _triggerFinish() {
    if (_hasFinished) return;
    _hasFinished = true;
    widget.onFinish?.call();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _triggerFinish();
        }
      },
      child: Center(
        child: Container(
          margin: .symmetric(horizontal: 24.w),
          padding: .only(top: 24.h, left: 24.w, right: 24.w, bottom: 0),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: .circular(20.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.dialogShadow,
                blurRadius: 20,
                spreadRadius: 5,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: .antiAlias,
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: .min,
              children: [
                // Icon circle
                Container(
                  padding: .all(16.w),
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.1),
                    shape: .circle,
                  ),
                  child: Icon(widget.icon, color: widget.color, size: 48.sp),
                ),
                verticalSpace(16),
                // Title
                Text(
                  widget.title,
                  textAlign: .center,
                  style: AppTextStyles.dialogTitle(widget.color),
                ),
                verticalSpace(8),
                // Message
                Text(
                  widget.message,
                  textAlign: .center,
                  style: AppTextStyles.dialogMessage,
                ),
                verticalSpace(20),
                // Linear Progress Indicator
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: widget.duration,
                  onEnd: () {
                    if (Navigator.of(context).canPop()) {
                      context.pop();
                    }
                    _triggerFinish();
                  },
                  builder: (context, value, child) {
                    return LinearProgressIndicator(
                      value: value,
                      backgroundColor: AppColors.progressBackground,
                      valueColor: AlwaysStoppedAnimation<Color>(widget.color),
                      minHeight: 4.h,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Standalone helper function for showing feedback dialogs
void showFeedbackDialog(
  BuildContext context, {
  required IconData icon,
  required Color color,
  required String title,
  required String message,
  VoidCallback? onFinish,
  Duration duration = const Duration(milliseconds: 2500),
}) {
  CustomFeedbackDialog.show(
    context,
    icon: icon,
    color: color,
    title: title,
    message: message,
    onFinish: onFinish,
    duration: duration,
  );
}
