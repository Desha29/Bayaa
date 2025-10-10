import 'package:crazy_phone_pos/features/auth/data/data_sources/user_data_source.dart';
import 'package:crazy_phone_pos/features/auth/data/repository/user_repository_imp.dart';
import 'package:crazy_phone_pos/features/auth/presentation/cubit/user_cubit.dart';
import 'package:crazy_phone_pos/features/products/data/data_source/category_data_source.dart';
import 'package:crazy_phone_pos/features/products/data/data_source/product_data_source.dart';
import 'package:crazy_phone_pos/features/products/data/repository/product_repository_imp.dart';
import 'package:crazy_phone_pos/features/products/presentation/cubit/product_cubit.dart';
import 'package:crazy_phone_pos/features/stock/presentation/widgets/product_card.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setup() {
  getIt.registerSingleton<UserCubit>(UserCubit(
      userRepository: UserRepositoryImp(userDataSource: UserDataSource())));
  getIt.registerSingleton<ProductCubit>(ProductCubit(
      productRepositoryInt: ProductRepositoryImp(
          productDataSource: ProductDataSource(),
          categoryDataSource: CategoryDataSource())));
}
