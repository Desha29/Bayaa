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
      return Left(CacheFailure("Failed to delete user"));
    }
  }

  @override
  Either<Failure, List<User>> getAllUsers() {
    try {
      final users = userDataSource.getAllUsers();
      return Right(users);
    } on Exception catch (e) {
      return Left(CacheFailure("Failed to get users"));
    }
  }

  @override
  Either<Failure, User> getUser(String username) {
    try {
      final user = userDataSource.getUser(username);
      if (user != null) {
        return Right(user);
      } else {
        return Left(CacheFailure("User not found"));
      }
    } on Exception catch (e) {
      return Left(CacheFailure("Failed to get user"));
    }
  }

  @override
  Either<Failure, void> saveUser(User user) {
    try {
      userDataSource.saveUser(user);
      return Right(null);
    } on Exception catch (e) {
      return Left(CacheFailure("Failed to save user"));
    }
  }
}
