import 'package:either_dart/either.dart';

import '../../../../core/error/failure.dart';
import '../../data/models/user_model.dart';

abstract class UserRepositoryInt {
  Future<Either<Failure, User>> getUser(String username);
  Future<Either<Failure, List<User>>> getAllUsers();
  Future<Either<Failure, void>> saveUser(User user);
  Future<Either<Failure, void>> updateUser(User user);
  Future<Either<Failure, void>> deleteUser(String username);
}
