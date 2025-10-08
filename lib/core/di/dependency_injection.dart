import 'package:crazy_phone_pos/features/auth/data/data_sources/user_data_source.dart';
import 'package:crazy_phone_pos/features/auth/data/repository/user_repository_imp.dart';
import 'package:crazy_phone_pos/features/auth/presentation/cubit/user_cubit.dart';
import 'package:get_it/get_it.dart';



final getIt = GetIt.instance;

void setup() {
  getIt.registerSingleton<UserRepositoryImp>(
      UserRepositoryImp(userDataSource: UserDataSource()));
  getIt.registerSingleton<UserCubit>(UserCubit(userRepository: UserRepositoryImp(userDataSource: UserDataSource())));

  
}
