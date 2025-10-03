abstract class UserStates {}

class UserInitial extends UserStates {}

class UserLoading extends UserStates {}

class UserSuccess extends UserStates {
  final String message;
  UserSuccess(this.message);
}

class UserFailure extends UserStates {
  final String error;
  UserFailure(this.error);
}

class UsersLoaded extends UserStates {
  final List users;
  UsersLoaded(this.users);
}
