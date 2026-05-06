enum NotificationType { points, profileView, other }

class NotificationModel {
  final String id;
  final String title;
  final String subtitle;
  final NotificationType type;
  final DateTime timestamp;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.timestamp,
    this.isRead = false,
  });
}
