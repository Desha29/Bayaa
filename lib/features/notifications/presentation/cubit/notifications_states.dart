import '../../../dashboard/data/models/notify_model.dart';

class NotificationsStates {}

class NotificationsLoading extends NotificationsStates {}

class NotificationsLoaded extends NotificationsStates {
  final List<NotifyItem> notifications;

  NotificationsLoaded(this.notifications);
}

class NotificationsError extends NotificationsStates {
  final String message;

  NotificationsError(this.message);
}
