import 'package:bayaa_pos/features/notifications/presentation/models/notification_view_data.dart';

class NotificationState {}

class NotificationsLoading extends NotificationState {}

class NotificationsLoaded extends NotificationState {
  final List<NotifyItem> notifications;

  NotificationsLoaded(this.notifications);
}

class NotificationsError extends NotificationState {
  final String message;

  NotificationsError(this.message);
}
