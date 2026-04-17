import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joby/core/helpers/spacing.dart';
import 'package:joby/core/themes/app_colors.dart';
import 'package:joby/features/users/advice/presentation/widgets/advice_footer.dart';
import 'package:joby/features/users/advice/presentation/widgets/custom_head_section.dart';
import 'package:joby/features/users/advice/presentation/widgets/custom_send_button.dart';
import 'package:joby/features/users/advice/presentation/widgets/success_state_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class AdviceScreen extends StatefulWidget {
  const AdviceScreen({super.key});

  @override
  State<AdviceScreen> createState() => _AdviceScreenState();
}

class _AdviceScreenState extends State<AdviceScreen> {
  final TextEditingController _messageController = TextEditingController();
  static const int _maxChars = 500;
  static const String _recipientEmail = "ismailmagdy920@gmail.com";
  bool _justSent = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  /// Send Feedback Logic & check if user has written a message
  Future<void> _sendFeedback() async {
    final message = _messageController.text.trim();

    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text(
              "Please write your feedback first",
              style: TextStyle(fontSize: 14.sp, color: Colors.white),
            ),
          ),
          backgroundColor: Colors.orange,
          behavior: .floating,
          margin: .all(20.r),
          shape: RoundedRectangleBorder(borderRadius: .circular(10.r)),
        ),
      );
      return;
    }

    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: _recipientEmail,
      queryParameters: {'subject': 'Joby App — User Feedback', 'body': message},
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
      setState(() => _justSent = true);
      _messageController.clear();
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not open email app. Please email us directly at $_recipientEmail',
            style: TextStyle(fontSize: 13.sp),
          ),
          backgroundColor: Colors.red,
          behavior: .floating,
          margin: .all(20.r),
          shape: RoundedRectangleBorder(borderRadius: .circular(10.r)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // App Bar
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Share Feedback",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20.sp,
            fontWeight: .bold,
          ),
        ),
      ),
      //
      body: SingleChildScrollView(
        padding: .symmetric(horizontal: 24.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            // Header
            CustomHeadSection(),
            //
            verticalSpace(36),
            //
            // Success State
            if (_justSent) ...[
              //
              SuccessStateWidget(
                onPressed: () => setState(() => _justSent = false),
              ),
              //
            ]
            // Feedback Form
            else ...[
              //
              Text(
                "Your Feedback",
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: .w600,
                  color: Colors.grey.shade700,
                ),
              ),
              //
              verticalSpace(10),
              //
              // Text field with character counter
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _messageController,
                builder: (context, value, _) {
                  final charCount = value.text.length;
                  final isNearLimit = charCount > _maxChars * 0.85;
                  return Column(
                    crossAxisAlignment: .end,
                    children: [
                      TextField(
                        controller: _messageController,
                        maxLines: 8,
                        minLines: 5,
                        maxLength: _maxChars,
                        buildCounter:
                            (
                              _, {
                              required currentLength,
                              required isFocused,
                              maxLength,
                            }) => null,
                        decoration: InputDecoration(
                          hintText:
                              "Share your ideas, bugs you found, or anything "
                              "you'd like us to improve...",
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14.sp,
                            height: 1.5,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          contentPadding: .all(16.r),
                          border: OutlineInputBorder(
                            borderRadius: .circular(16.r),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: .circular(16.r),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: .circular(16.r),
                            borderSide: BorderSide(
                              color: AppColors.primaryColor,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      verticalSpace(4),
                      Text(
                        "$charCount / $_maxChars",
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: isNearLimit
                              ? Colors.orange
                              : Colors.grey.shade400,
                        ),
                      ),
                    ],
                  );
                },
              ),
              //
              verticalSpace(28),
              //
              // Send Button
              CustomSendButton(onPressed: _sendFeedback),
              //
              verticalSpace(16),
              //
              AdviceFooter(),
              //
            ],
            //
          ],
        ),
      ),
    );
  }
}
