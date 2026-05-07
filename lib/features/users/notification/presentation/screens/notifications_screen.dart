import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joby/core/themes/app_colors.dart';
import 'package:joby/core/widgets/custom_app_bar.dart';
import 'package:joby/core/widgets/error_screen.dart';
import '../../manager/notification_cubit.dart';
import '../../manager/notification_state.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/notification_tile.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // App Bar
      appBar: CustomAppBar(
        text: "Notifications",
        actions: [
          BlocBuilder<NotificationCubit, NotificationState>(
            builder: (context, state) {
              if (state is NotificationLoaded) {
                final hasUnread = state.notifications.any((n) => !n.isRead);
                if (hasUnread) {
                  return TextButton(
                    onPressed: () {
                      context.read<NotificationCubit>().markAllAsRead();
                    },
                    child: Text(
                      "Mark all as read",
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 10.sp,
                        fontWeight: .w600,
                      ),
                    ),
                  );
                }
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      //
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          // Loading State
          if (state is NotificationLoading) {
            return const Center(child: CupertinoActivityIndicator());
            // Error State
          } else if (state is NotificationError) {
            return ErrorScreen(errorText: state.message);
          }
          // Empty State
          else if (state is NotificationEmpty) {
            return const EmptyStateWidget();
          }
          // Loaded State
          else if (state is NotificationLoaded) {
            final notifications = state.notifications;
            return ListView.builder(
              padding: .symmetric(vertical: 12.h),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                return TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 400 + (index * 100)),
                  tween: Tween(begin: 0.0, end: 1.0),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(50 * (1 - value), 0),
                      child: Opacity(opacity: value, child: child),
                    );
                  },
                  child: NotificationTile(
                    notification: notifications[index],
                    onTap: () {
                      // Handle tap navigate to profile or points screen
                    },
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
