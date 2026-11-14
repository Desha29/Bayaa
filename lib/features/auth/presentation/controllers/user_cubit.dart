import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bayaa_pos/preview/data/preview_data.dart';
import 'package:bayaa_pos/features/auth/presentation/models/user_view_data.dart';
import 'package:bayaa_pos/features/auth/presentation/sources/user_directory_source.dart';
import 'package:bayaa_pos/features/auth/presentation/controllers/user_state.dart';

/// Only holds presentation state; the login button opens the showcase.
class UserCubit extends Cubit<UserState> {
  UserCubit({required this.userRepository}) : super(UserInitial());
  final UserDirectorySource userRepository;
  static UserCubit get(context) => BlocProvider.of(context);
  UserViewData currentUser = PreviewData.users.first;
  bool _isPasswordVisible = false;
  bool get isPasswordVisible => _isPasswordVisible;
  List<UserViewData> get users => PreviewData.users;
  void getAllUsers() => emit(UsersLoaded(users));
  void getUser(String username) => getAllUsers();
  void login(String username, String password) {
    currentUser = PreviewData.users.first;
    emit(LoginSuccess());
  }

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    emit(PasswordVisibilityChanged(_isPasswordVisible));
  }

  void logout() => emit(UserInitial());
}
