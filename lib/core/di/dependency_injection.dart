import 'package:crazy_phone_pos/features/auth/data/data_sources/user_data_source.dart';
import 'package:crazy_phone_pos/features/auth/data/repository/user_repository_imp.dart';
import 'package:crazy_phone_pos/features/auth/presentation/cubit/user_cubit.dart';
import 'package:crazy_phone_pos/features/products/data/data_source/category_data_source.dart';
import 'package:crazy_phone_pos/features/products/data/data_source/product_data_source.dart';
import 'package:crazy_phone_pos/features/products/data/repository/product_repository_imp.dart';
import 'package:crazy_phone_pos/features/products/presentation/cubit/product_cubit.dart';
import 'package:crazy_phone_pos/features/stock/presentation/cubit/stock_cubit.dart';
import '../../features/stock_summary/presentation/cubit/stock_summary_cubit.dart';
import 'package:get_it/get_it.dart';

import '../../features/arp/data/arp_repository_impl.dart';
import '../../features/arp/domain/arp_repository.dart';
import '../../features/arp/presentation/cubit/arp_cubit.dart';
import '../../features/notifications/presentation/cubit/notifications_cubit.dart';
import '../../features/sales/data/repository/sales_repository_impl.dart';

import '../../features/sales/presentation/cubit/sales_cubit.dart';
import '../../features/settings/data/data_source/store_info_data_source.dart';
import '../../features/settings/data/repository/settings_repository_imp.dart';
import '../../features/settings/presentation/cubit/settings_cubit.dart';
import '../../core/utils/hive_helper.dart';
import '../../features/arp/data/repositories/session_repository_impl.dart';

final getIt = GetIt.instance;

void setup() {
  // Repositories
  getIt.registerSingleton<SessionRepositoryImpl>(SessionRepositoryImpl());

  getIt.registerSingleton<UserCubit>(UserCubit(
      userRepository: UserRepositoryImp(userDataSource: UserDataSource()),
      sessionRepository: getIt<SessionRepositoryImpl>()));

  getIt.registerSingleton<ProductCubit>(ProductCubit(
      productRepositoryInt: ProductRepositoryImp(
          productDataSource: ProductDataSource(),
          categoryDataSource: CategoryDataSource())));


  final salesRepo = SalesRepositoryImpl(
    productsBox: HiveHelper.productsBox,
    salesBox: HiveHelper.salesBox,
  );


  getIt.registerSingleton<SalesRepositoryImpl>(salesRepo);

  getIt.registerSingleton<SalesCubit>(SalesCubit(repository: salesRepo));

  getIt.registerSingleton<StockCubit>(StockCubit(
      productRepository: ProductRepositoryImp(
          productDataSource: ProductDataSource(),
          categoryDataSource: CategoryDataSource())));

  getIt.registerSingleton<NotificationsCubit>(NotificationsCubit());

  final arpRepo = ArpRepositoryImpl();
  getIt.registerSingleton<ArpRepository>(arpRepo);

  getIt.registerSingleton<ArpCubit>(ArpCubit(arpRepo));

  getIt.registerFactory<StockSummaryCubit>(
      () => StockSummaryCubit()); 

 

  final storeInfoRepo = StoreInfoRepository(
    dataSource: StoreInfoDataSource(),
  );
  getIt.registerSingleton<StoreInfoRepository>(storeInfoRepo);

  getIt.registerSingleton<SettingsCubit>(SettingsCubit(
    userCubit: getIt<UserCubit>(),
    storeRepository: storeInfoRepo,
  ));
}
