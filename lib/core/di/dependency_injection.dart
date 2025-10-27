import 'package:crazy_phone_pos/features/auth/data/data_sources/user_data_source.dart';
import 'package:crazy_phone_pos/features/auth/data/repository/user_repository_imp.dart';
import 'package:crazy_phone_pos/features/auth/presentation/cubit/user_cubit.dart';
import 'package:crazy_phone_pos/features/products/data/data_source/category_data_source.dart';
import 'package:crazy_phone_pos/features/products/data/data_source/product_data_source.dart';
import 'package:crazy_phone_pos/features/products/data/repository/product_repository_imp.dart';
import 'package:crazy_phone_pos/features/products/presentation/cubit/product_cubit.dart';
import 'package:crazy_phone_pos/features/products/data/models/product_model.dart';
import 'package:crazy_phone_pos/features/stock/presentation/cubit/stock_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/adapters.dart';

import '../../features/notifications/presentation/cubit/notifications_cubit.dart';
import '../../features/sales/data/models/sale_model.dart';
import '../../features/sales/data/repository/sales_repository_impl.dart';
import '../../features/sales/presentation/cubit/sales_cubit.dart';

final getIt = GetIt.instance;

void setup() {
  getIt.registerSingleton<UserCubit>(UserCubit(
      userRepository: UserRepositoryImp(userDataSource: UserDataSource())));
  getIt.registerSingleton<ProductCubit>(ProductCubit(
      productRepositoryInt: ProductRepositoryImp(
          productDataSource: ProductDataSource(),
          categoryDataSource: CategoryDataSource())));
  getIt.registerSingleton<SalesCubit>(SalesCubit(
      repository: SalesRepositoryImpl(
          productsBox: Hive.box<Product>('productsBox'),
          salesBox: Hive.box<Sale>('salesBox'))));
  getIt.registerSingleton<StockCubit>(StockCubit(
      productRepository: ProductRepositoryImp(
          productDataSource: ProductDataSource(),
          categoryDataSource: CategoryDataSource())));
  getIt.registerSingleton<NotificationsCubit>(NotificationsCubit());
}
