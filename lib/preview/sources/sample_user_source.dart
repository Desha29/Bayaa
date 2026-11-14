import 'package:either_dart/either.dart';
import 'package:bayaa_pos/shared/foundation/preview_failure.dart';
import 'package:bayaa_pos/preview/data/preview_data.dart';
import 'package:bayaa_pos/features/auth/presentation/sources/user_directory_source.dart';
import 'package:bayaa_pos/features/auth/presentation/models/user_view_data.dart';

class SampleUserSource implements UserDirectorySource {
  @override
  Future<Either<Failure, UserViewData>> getUser(String username) async =>
      Right(PreviewData.users.first);
  @override
  Future<Either<Failure, List<UserViewData>>> getAllUsers() async =>
      Right(PreviewData.users);
}
