import '../../../arp/data/models/session_model.dart';

abstract class UserStates {}

class UserInitial extends UserStates {}

class UserLoading extends UserStates {}

class CloseSessionLoading extends UserStates {}

class UserSuccess extends UserStates {
  final String message;
  
  UserSuccess(this.message);
}

class UserSuccessWithReport extends UserStates {
  final String message;
  final dynamic report;
  final Session session;
  UserSuccessWithReport(this.message, this.report, this.session);
}

class UserFailure extends UserStates {
  final String error;
  UserFailure(this.error);
}

class UsersLoaded extends UserStates {
  final List users;
  UsersLoaded(this.users);
}

class PasswordVisibilityChanged extends UserStates {
  final bool isVisible;
  PasswordVisibilityChanged(this.isVisible);
}
