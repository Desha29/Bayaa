import 'package:either_dart/either.dart';
import 'package:crazy_phone_pos/core/error/failure.dart';
import 'package:crazy_phone_pos/features/auth/data/data_sources/user_data_source.dart';
import 'package:crazy_phone_pos/features/auth/data/models/user_model.dart';
import 'package:crazy_phone_pos/features/auth/domain/repository/user_repository_int.dart';

class UserRepositoryImpl implements UserRepositoryInt {
  final UserDataSource _userDataSource;

  UserRepositoryImpl(this._userDataSource);

  @override
  Either<Failure, List<User>> getAllUsers() {
    try {
      final users = _userDataSource.getAllUsers();
      return Right(users);
    } catch (e) {
      return Left(CacheFailure( e.toString()));
    }
  }

  @override
  Either<Failure, User> getUser(String username) {
    try {
      final user = _userDataSource.getUser(username);
      if (user != null) {
        return Right(user);
      } else {
        return Left(CacheFailure( "User not found"));
      }
    } catch (e) {
      return Left(CacheFailure( e.toString()));
    }
  }

  @override
  Either<Failure, void> saveUser(User user) {
    try {
      _userDataSource.saveUser(user);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure( e.toString()));
    }
  }

  @override
  Either<Failure, void> updateUser(User user) {
    try {
      _userDataSource.updateUser(user);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Either<Failure, void> deleteUser(String username) {
    try {
      _userDataSource.deleteUser(username);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure( e.toString()));
    }
  }
}
