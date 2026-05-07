import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ionicons/ionicons.dart';
import 'package:joby/core/helpers/spacing.dart';
import 'package:joby/core/themes/app_colors.dart';
import '../../data/models/notification_model.dart';

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  String _formatTimeAgo(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inDays > 0) return "${diff.inDays}d ago";
    if (diff.inHours > 0) return "${diff.inHours}h ago";
    if (diff.inMinutes > 0) return "${diff.inMinutes}m ago";
    return "Just now";
  }

  IconData _getIconData() {
    switch (notification.type) {
      case .points:
        return Ionicons.gift_outline;
      case .profileView:
        return Ionicons.eye_outline;
      case .other:
        return Ionicons.notifications_outline;
    }
  }

  Color _getIconColor() {
    switch (notification.type) {
      case .points:
        return AppColors.primaryColor;
      case .profileView:
        return AppColors.primaryColor;
      case .other:
        return AppColors.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isUnread = !notification.isRead;
    final iconColor = _getIconColor();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: .symmetric(horizontal: 16.w, vertical: 8.h),
        padding: .all(16.r),
        decoration: BoxDecoration(
          color: isUnread
              ? AppColors.primaryColor.withValues(alpha: 0.05)
              : Colors.white,
          borderRadius: .circular(16.r),
          border: .all(
            color: isUnread
                ? AppColors.primaryColor.withValues(alpha: 0.2)
                : Colors.grey.shade200,
          ),
          boxShadow: [
            if (isUnread)
              BoxShadow(
                color: AppColors.primaryColor.withValues(alpha: 0.05),
                blurRadius: 10.r,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          crossAxisAlignment: .start,
          children: [
            // Icon Background
            Container(
              padding: .all(12.r),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.05),
                shape: .circle,
              ),
              child: Icon(_getIconData(), color: iconColor, size: 22.sp),
            ),
            //
            horizontalSpace(16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Row(
                    mainAxisAlignment: .spaceBetween,
                    children: [
                      // Title
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: isUnread ? .bold : .w600,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: .ellipsis,
                        ),
                      ),
                      //
                      horizontalSpace(8),
                      // Timestamp
                      Text(
                        _formatTimeAgo(notification.timestamp),
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      //
                    ],
                  ),
                  //
                  verticalSpace(6),
                  // Subtitle
                  Text(
                    notification.subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isUnread ? Colors.black87 : Colors.grey.shade500,
                      height: 1.4,
                    ),
                  ),
                  //
                ],
              ),
            ),
            if (isUnread) ...[
              //
              horizontalSpace(12),
              // Unread Indicator
              Column(
                mainAxisAlignment: .center,
                children: [
                  //
                  verticalSpace(8),
                  //
                  Container(
                    width: 10.r,
                    height: 10.r,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      shape: .circle,
                    ),
                  ),
                  //
                ],
              ),
              //
            ],
          ],
        ),
      ),
    );
  }
}
