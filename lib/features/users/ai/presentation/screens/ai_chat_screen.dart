import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ionicons/ionicons.dart';
import 'package:joby/core/helpers/spacing.dart';
import 'package:joby/core/themes/app_colors.dart';
import 'package:joby/features/users/ai/data/models/chat_message_model.dart';
import '../../manager/ai_chat_cubit.dart';
import '../../manager/ai_chat_state.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Suggested prompts shown when chat is fresh (only welcome message visible)
  static const List<String> _suggestedPrompts = [
    '💼  Tips to improve my CV',
    '🎯  Mock interview questions for my field',
    '🚀  Suggest a career roadmap',
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendPrompt(String prompt) {
    // Strip the leading emoji + spaces
    final clean = prompt
        .replaceFirst(RegExp(r'^[\p{Emoji}\s]+', unicode: true), '')
        .trim();
    context.read<AiChatCubit>().sendMessage(clean);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          "Joby Assistant",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20.sp,
            fontWeight: .bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: "Clear chat history",
            icon: Icon(
              Ionicons.trash_outline,
              color: Colors.grey.shade500,
              size: 22.sp,
            ),
            onPressed: () => _showClearDialog(context),
          ),
          horizontalSpace(4),
        ],
      ),
      body: BlocConsumer<AiChatCubit, AiChatState>(
        listener: (context, state) {
          if (state is AiChatUpdated) _scrollToBottom();
        },
        builder: (context, state) {
          final messages = state is AiChatUpdated
              ? state.messages
              : <ChatMessageModel>[];
          final isLoading = state is AiChatUpdated && state.isLoading;
          final showPrompts = messages.length <= 1 && !isLoading;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: .symmetric(horizontal: 16.w, vertical: 20.h),
                  itemCount:
                      messages.length +
                      (isLoading ? 1 : 0) +
                      (showPrompts ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Show message bubbles first
                    if (index < messages.length) {
                      return _buildChatBubble(
                        messages[index].text,
                        messages[index].isAi,
                      );
                    }
                    // Suggested prompts (shown after welcome msg when empty)
                    if (showPrompts && index == messages.length) {
                      return _buildSuggestedPrompts();
                    }
                    // Loading typing indicator
                    if (isLoading) return _buildLoadingBubble();
                    return const SizedBox.shrink();
                  },
                ),
              ),
              _buildInputArea(context, isLoading),
              // Bottom padding to clear the floating nav bar (height 68 + 25 padding)
              verticalSpace(105),
            ],
          );
        },
      ),
    );
  }

  // ─── Widgets ──────────────────────────────────────────────────────────────

  Widget _buildChatBubble(String text, bool isAi) {
    return Padding(
      padding: .only(bottom: 20.h),
      child: Row(
        crossAxisAlignment: .start,
        mainAxisAlignment: isAi ? .start : .end,
        children: [
          if (isAi) ...[
            CircleAvatar(
              radius: 16.r,
              backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
              child: Icon(
                Icons.auto_awesome,
                color: AppColors.primaryColor,
                size: 18.sp,
              ),
            ),
            horizontalSpace(10),
          ],
          Flexible(
            child: Container(
              padding: .symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: isAi ? Colors.grey.shade100 : AppColors.primaryColor,
                borderRadius: .only(
                  topLeft: .circular(16.r),
                  topRight: .circular(16.r),
                  bottomLeft: isAi ? .zero : .circular(16.r),
                  bottomRight: isAi ? .circular(16.r) : .zero,
                ),
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: isAi ? Colors.black87 : Colors.white,
                  fontSize: 15.sp,
                  height: 1.45,
                ),
              ),
            ),
          ),
          if (!isAi) ...[
            horizontalSpace(10),
            CircleAvatar(
              radius: 16.r,
              backgroundColor: Colors.grey.shade200,
              child: Icon(
                Ionicons.person,
                color: Colors.grey.shade600,
                size: 18.sp,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingBubble() {
    return Padding(
      padding: .only(bottom: 20.h),
      child: Row(
        crossAxisAlignment: .start,
        children: [
          CircleAvatar(
            radius: 16.r,
            backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
            child: Icon(
              Icons.auto_awesome,
              color: AppColors.primaryColor,
              size: 18.sp,
            ),
          ),
          horizontalSpace(10),
          Container(
            padding: .symmetric(horizontal: 18.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: .only(
                topLeft: .circular(16.r),
                topRight: .circular(16.r),
                bottomRight: .circular(16.r),
              ),
            ),
            child: const _TypingIndicator(),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestedPrompts() {
    return Padding(
      padding: .only(top: 8.h, bottom: 20.h),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Padding(
            padding: .only(left: 4.w, bottom: 10.h),
            child: Text(
              'Try asking:',
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey.shade500,
                fontWeight: .w500,
              ),
            ),
          ),
          ..._suggestedPrompts.map(
            (prompt) => GestureDetector(
              onTap: () => _sendPrompt(prompt),
              child: Container(
                width: double.infinity,
                margin: .only(bottom: 8.h),
                padding: .symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.05),
                  borderRadius: .circular(12.r),
                  border: Border.all(
                    color: AppColors.primaryColor.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  prompt,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(BuildContext context, bool isLoading) {
    return Container(
      padding: .symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: .circular(25.r),
              ),
              child: TextField(
                controller: _messageController,
                maxLines: 3,
                minLines: 1,
                enabled: !isLoading,
                textInputAction: .send,
                onSubmitted: isLoading
                    ? null
                    : (text) {
                        _messageController.clear();
                        context.read<AiChatCubit>().sendMessage(text);
                      },
                decoration: InputDecoration(
                  hintText: 'Ask Joby about your career...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14.sp,
                  ),
                  border: .none,
                  contentPadding: .symmetric(horizontal: 20.w, vertical: 12.h),
                ),
              ),
            ),
          ),
          horizontalSpace(10),
          GestureDetector(
            onTap: isLoading
                ? null
                : () {
                    final text = _messageController.text;
                    _messageController.clear();
                    context.read<AiChatCubit>().sendMessage(text);
                  },
            child: CircleAvatar(
              radius: 22.r,
              backgroundColor: isLoading
                  ? Colors.grey.shade300
                  : AppColors.primaryColor,
              child: Icon(Ionicons.send, color: Colors.white, size: 20.sp),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: .circular(16.r)),
        title: Text(
          'Clear Chat History',
          style: TextStyle(fontSize: 17.sp, fontWeight: .bold),
        ),
        content: Text(
          'This will delete all messages. The conversation will start fresh.',
          style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AiChatCubit>().clearHistory();
            },
            child: Text(
              'Clear',
              style: TextStyle(
                color: Colors.red,
                fontSize: 14.sp,
                fontWeight: .bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Typing Indicator (animated 3-dot bubble) ────────────────────────────────

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, _) {
        return Row(
          mainAxisSize: .min,
          children: List.generate(3, (i) {
            // Stagger each dot by 1/3 of the cycle
            final phase = ((_controller.value - i / 3) % 1.0);
            final bounce = phase < 0.5 ? phase * 2 : (1.0 - phase) * 2;
            return Transform.translate(
              offset: Offset(0, -5.h * bounce),
              child: Container(
                margin: .symmetric(horizontal: 2.5.w),
                width: 7.w,
                height: 7.w,
                decoration: BoxDecoration(
                  color: Colors.grey.shade500,
                  shape: .circle,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
