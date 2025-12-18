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
  final dynamic report; // Use dynamic to avoid import cycle if needed, or import DailyReport
  UserSuccessWithReport(this.message, this.report);
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
