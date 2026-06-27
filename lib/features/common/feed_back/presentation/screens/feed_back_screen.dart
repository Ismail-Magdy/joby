import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joby/core/helpers/spacing.dart';
import 'package:joby/core/themes/app_colors.dart';
import 'package:joby/core/widgets/custom_app_bar.dart';
import 'package:joby/core/widgets/snack_bar_text.dart';
import 'package:joby/features/common/feed_back/manager/advice_cubit.dart';
import 'package:joby/features/common/feed_back/manager/advice_state.dart';
import 'package:joby/features/common/feed_back/presentation/widgets/feed_back_footer.dart';
import 'package:joby/features/common/feed_back/presentation/widgets/custom_head_section.dart';
import 'package:joby/features/common/feed_back/presentation/widgets/custom_send_button.dart';
import 'package:joby/features/common/feed_back/presentation/widgets/success_state_widget.dart';

class FeedBackScreen extends StatefulWidget {
  const FeedBackScreen({super.key});

  @override
  State<FeedBackScreen> createState() => _FeedBackScreenState();
}

class _FeedBackScreenState extends State<FeedBackScreen> {
  final TextEditingController _messageController = TextEditingController();
  static const int _maxChars = 500;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  /// Validate & trigger feedback send via Cubit
  void _sendFeedback() {
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
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(20.r),
          shape: RoundedRectangleBorder(borderRadius: .circular(10.r)),
        ),
      );
      return;
    }

    context.read<AdviceCubit>().sendFeedback(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // App Bar
      appBar: CustomAppBar(text: "Feedback"),
      //
      body: BlocConsumer<AdviceCubit, AdviceState>(
        //
        listener: (context, state) {
          if (state is AdviceSent) {
            _messageController.clear();
          } else if (state is AdviceError) {
            //
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: SnackBarText(title: state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                margin: .all(20.r),
                shape: RoundedRectangleBorder(borderRadius: .circular(10.r)),
              ),
            );
            //
          }
        },
        //
        builder: (context, state) {
          return SingleChildScrollView(
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
                if (state is AdviceSent) ...[
                  //
                  SuccessStateWidget(
                    onPressed: () => context.read<AdviceCubit>().reset(),
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
                      final isLimit = charCount >= _maxChars;
                      final isNearLimit = charCount >= _maxChars * 0.85;
                      return Column(
                        crossAxisAlignment: .end,
                        children: [
                          //
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
                                fontSize: 13.sp,
                                height: 1.5,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              contentPadding: .all(16.r),
                              border: OutlineInputBorder(
                                borderRadius: .circular(16.r),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade200,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: .circular(16.r),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade200,
                                ),
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
                          //
                          verticalSpace(4),
                          //
                          Text(
                            "$charCount / $_maxChars",
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: isLimit
                                  ? Colors.red
                                  : isNearLimit
                                  ? Colors.orange
                                  : Colors.grey.shade400,
                            ),
                          ),
                          //
                        ],
                      );
                    },
                  ),
                  //
                  verticalSpace(28),
                  //
                  // Send Button (disabled while sending)
                  CustomSendButton(
                    onPressed: state is AdviceSending ? null : _sendFeedback,
                    isLoading: state is AdviceSending,
                  ),
                  //
                  verticalSpace(16),
                  //
                  FeedBackFooter(),
                  //
                ],
                //
              ],
            ),
          );
        },
      ),
    );
  }
}
