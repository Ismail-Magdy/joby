import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:joby/core/helpers/extensions.dart';
import 'package:joby/core/themes/app_colors.dart';
import '../../manager/notification_cubit.dart';
import '../../manager/notification_state.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/notification_tile.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Notifications",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20.sp,
            fontWeight: .bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
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
                        fontSize: 14.sp,
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
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(child: CupertinoActivityIndicator());
          } else if (state is NotificationError) {
            return Center(
              child: Text(
                state.message,
                style: TextStyle(color: Colors.red, fontSize: 16.sp),
              ),
            );
          } else if (state is NotificationEmpty) {
            return const EmptyStateWidget();
          } else if (state is NotificationLoaded) {
            final notifications = state.notifications;
            return ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 12.h),
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
                      // Handle tap, e.g. navigate to profile or points screen
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
