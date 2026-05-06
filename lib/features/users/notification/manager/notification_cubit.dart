import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/notification_model.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit() : super(NotificationLoading());

  // In-memory mock data
  List<NotificationModel> _notifications = [];

  Future<void> fetchNotifications() async {
    emit(NotificationLoading());
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Mock Data
      _notifications = [
        NotificationModel(
          id: "1",
          title: "Great news",
          subtitle: "A company from Cairo just viewed your profile",
          type: .profileView,
          timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
          isRead: false,
        ),
        NotificationModel(
          id: "2",
          title: "Daily Check in Bonus",
          subtitle: "You just earned 10 points for opening the app today",
          type: .points,
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          isRead: false,
        ),
        NotificationModel(
          id: "3",
          title: "Profile View Alert",
          subtitle: "Tech Solutions Ltd checked out your CV",
          type: .profileView,
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          isRead: true,
        ),
        NotificationModel(
          id: "4",
          title: "Welcome to Joby",
          subtitle: "We are thrilled to have you on board. Start exploring",
          type: .other,
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          isRead: true,
        ),
      ];

      if (_notifications.isEmpty) {
        emit(NotificationEmpty());
      } else {
        emit(NotificationLoaded(List.from(_notifications)));
      }
    } catch (e) {
      emit(NotificationError('Failed to load notifications'));
    }
  }

  void markAllAsRead() {
    if (state is NotificationLoaded) {
      for (var notification in _notifications) {
        notification.isRead = true;
      }
      emit(NotificationLoaded(List.from(_notifications)));
    }
  }
}
