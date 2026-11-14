import 'package:either_dart/either.dart';

import 'package:bayaa_pos/shared/foundation/preview_failure.dart';
import 'package:bayaa_pos/features/auth/presentation/models/user_view_data.dart';

abstract class UserDirectorySource {
  Future<Either<Failure, UserViewData>> getUser(String username);
  Future<Either<Failure, List<UserViewData>>> getAllUsers();
}
