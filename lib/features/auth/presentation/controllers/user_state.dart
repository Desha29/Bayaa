abstract class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserSuccess extends UserState {
  final String message;

  UserSuccess(this.message);
}

class LoginSuccess extends UserState {}

class UserFailure extends UserState {
  final String error;
  UserFailure(this.error);
}

class UsersLoaded extends UserState {
  final List users;
  UsersLoaded(this.users);
}

class PasswordVisibilityChanged extends UserState {
  final bool isVisible;
  PasswordVisibilityChanged(this.isVisible);
}
