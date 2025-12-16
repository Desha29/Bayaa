import 'package:crazy_phone_pos/features/auth/data/models/user_model.dart';
import 'package:crazy_phone_pos/features/auth/domain/repository/user_repository_int.dart';
import 'package:crazy_phone_pos/features/auth/presentation/cubit/user_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserCubit extends Cubit<UserStates> {
  UserCubit({required this.userRepository}) : super(UserInitial());
  final UserRepositoryInt userRepository;
  static UserCubit get(context) => BlocProvider.of(context);
  late User currentUser;
  bool _isPasswordVisible = false;

  bool get isPasswordVisible => _isPasswordVisible;

  void getAllUsers() async {
    emit(UserLoading());
    final result = userRepository.getAllUsers();
    print(result.toString());
    result.fold(
      (failure) => emit(UserFailure(failure.message)),
      (users) => emit(UsersLoaded(users)),
    );
  }

 void deleteUser(String username) async {
  emit(UserLoading());
  final result = userRepository.deleteUser(username);
  result.fold(
    (failure) => emit(UserFailure(failure.message)),
    (_) {
      emit(UserSuccess("تم حذف المستخدم بنجاح"));
      getAllUsers(); 
    },
  );
}

void saveUser(User user) async {
  emit(UserLoading());
  final result = userRepository.saveUser(user);
  result.fold(
    (failure) => emit(UserFailure(failure.message)),
    (_) {
      emit(UserSuccess("تم إضافة المستخدم بنجاح"));
      getAllUsers(); 
    },
  );
}
void updateUser(User user) async {
  emit(UserLoading());
  final result = userRepository.updateUser(user);
  result.fold(
    (failure) => emit(UserFailure(failure.message)),
    (_) {
      if (currentUser.username == user.username) {
        currentUser = user;
      }
      emit(UserSuccess("تم تحديث المستخدم بنجاح"));
      getAllUsers(); 
    },
  );
}
  void getUser(String username) async {
    emit(UserLoading());
    final result = userRepository.getUser(username);
    result.fold(
      (failure) => emit(UserFailure(failure.message)),
      (user) =>
          emit(UserSuccess("User fetched successfully: ${user.username}")),
    );
  }

  void login(String username, String password) async {
    emit(UserLoading());
    final result = userRepository.getUser(username);
    result.fold(
      (failure) => emit(UserFailure(failure.message)),
      (user) {
        if (user.password == password) {
          currentUser = user;
          emit(UserSuccess("تم تسجيل الدخول بنجاح"));
        } else {
          emit(UserFailure("كلمة المرور غير صحيحة"));
        }
      },
    );
  }

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    emit(PasswordVisibilityChanged(_isPasswordVisible));
  }

  void logout() {
    currentUser = User(
        name: '',
        phone: '',
        username: '',
        password: '',
        userType: UserType.cashier);
    emit(UserInitial());
  }
}
