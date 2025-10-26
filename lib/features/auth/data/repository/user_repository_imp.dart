import 'package:crazy_phone_pos/core/error/failure.dart';
import 'package:crazy_phone_pos/features/auth/data/data_sources/user_data_source.dart';
import 'package:crazy_phone_pos/features/auth/data/models/user_model.dart';
import 'package:crazy_phone_pos/features/auth/domain/repository/user_repository_int.dart';
import 'package:either_dart/src/either.dart';

class UserRepositoryImp extends UserRepositoryInt {
  UserDataSource userDataSource;
  UserRepositoryImp({required this.userDataSource});

  @override
  Either<Failure, void> deleteUser(String username) {
    try {
      userDataSource.deleteUser(username);
      return Right(null);
    } on Exception catch (e) {
      return Left(CacheFailure("فشل في حذف المستخدم"));
    }
  }

  @override
  Either<Failure, List<User>> getAllUsers() {
    try {
      final users = userDataSource.getAllUsers();
      for (var user in users) {
        print('User: ${user.username}, Password: ${user.password}');
      }
      return Right(users);
    } on Exception catch (e) {
      return Left(CacheFailure("فشل في جلب المستخدمين"));
    }
  }

  @override
  Either<Failure, User> getUser(String username) {
    try {
      final user = userDataSource.getUser(username);
      if (user != null) {
        return Right(user);
      } else {
        return Left(CacheFailure("المستخدم غير موجود"));
      }
    } on Exception catch (e) {
      return Left(CacheFailure("فشل في جلب المستخدم"));
    }
  }

  @override
  Either<Failure, void> saveUser(User user) {
    try {
      userDataSource.saveUser(user);
      return Right(null);
    } on Exception catch (e) {
      return Left(CacheFailure("فشل في حفظ المستخدم"));
    }
  }

  @override
  Either<Failure, void> updateUser(User user) {
    try {
      userDataSource.updateUser(user);
      return const Right(null);
    } on Exception catch (e) {
      return Left(CacheFailure("فشل في تحديث المستخدم: ${e.toString()}"));
    }
  }
}
