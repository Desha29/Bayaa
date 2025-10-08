import 'package:either_dart/either.dart';

import '../../../../core/error/failure.dart';
import '../../data/models/user_model.dart';

abstract class UserRepositoryInt {
  Either<Failure, User> getUser(String username);
  Either<Failure, List<User>> getAllUsers();
  Either<Failure, void> saveUser(User user);
  Either<Failure, void> updateUser(User user);
  Either<Failure, void> deleteUser(String username);
}
