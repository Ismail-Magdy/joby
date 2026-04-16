import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";
import "package:ionicons/ionicons.dart";
import "package:joby/core/helpers/spacing.dart";
import "package:joby/core/themes/app_colors.dart";
import "package:joby/features/users/ai/data/models/chat_message_model.dart";
import "../../manager/ai_chat_cubit.dart";
import "../../manager/ai_chat_state.dart";

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      //
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          mainAxisAlignment: .center,
          children: [
            Text(
              "Joby Assistant",
              style: TextStyle(
                color: Colors.black87,
                fontSize: 20.sp,
                fontWeight: .bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      //
      body: BlocConsumer<AiChatCubit, AiChatState>(
        listener: (context, state) {
          if (state is AiChatUpdated) {
            _scrollToBottom();
          }
        },
        builder: (context, state) {
          List<ChatMessageModel> messages = [];
          bool isLoading = false;
          if (state is AiChatUpdated) {
            messages = state.messages;
            isLoading = state.isLoading;
          }
          return Column(
            children: [
              //
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: .symmetric(horizontal: 16.w, vertical: 20.h),
                  itemCount: messages.length + (isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == messages.length && isLoading) {
                      return _buildLoadingBubble();
                    }
                    final message = messages[index];
                    return _buildChatBubble(message.text, message.isAi);
                  },
                ),
              ),
              //
              _buildInputArea(context, isLoading),
              //
              verticalSpace(100),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isAi) {
    return Padding(
      padding: .only(bottom: 20.h),
      child: Row(
        crossAxisAlignment: .start,
        mainAxisAlignment: isAi ? .start : .end,
        children: [
          if (isAi) ...[
            //
            CircleAvatar(
              radius: 16.r,
              backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
              child: Icon(
                Icons.auto_awesome,
                color: AppColors.primaryColor,
                size: 18.sp,
              ),
            ),
            //
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
                  bottomLeft: isAi ? const .circular(0) : .circular(16.r),
                  bottomRight: isAi ? .circular(16.r) : const .circular(0),
                ),
              ),
              //
              child: Text(
                text,
                style: TextStyle(
                  color: isAi ? Colors.black87 : Colors.white,
                  fontSize: 15.sp,
                  height: 1.4,
                ),
              ),
              //
            ),
          ),
          if (!isAi) ...[
            horizontalSpace(10),
            //
            CircleAvatar(
              radius: 16.r,
              backgroundColor: Colors.grey.shade200,
              child: Icon(
                Ionicons.person,
                color: Colors.grey.shade600,
                size: 18.sp,
              ),
            ),
            //
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
            padding: .symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: .only(
                topLeft: .circular(16.r),
                topRight: .circular(16.r),
                bottomRight: .circular(16.r),
              ),
            ),
            child: SizedBox(
              width: 30.w,
              height: 15.h,
              child: const LinearProgressIndicator(
                backgroundColor: Colors.transparent,
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
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
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
                decoration: InputDecoration(
                  hintText: "Ask Joby about your career...",
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
              backgroundColor: isLoading ? Colors.grey : AppColors.primaryColor,
              child: Icon(Ionicons.send, color: Colors.white, size: 20.sp),
            ),
          ),
        ],
      ),
    );
  }
}
// 