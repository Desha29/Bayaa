import 'package:bayaa_pos/preview/sources/sample_user_source.dart';
import 'package:bayaa_pos/features/auth/presentation/sources/user_directory_source.dart';
import 'package:bayaa_pos/features/auth/presentation/controllers/user_cubit.dart';
import 'package:bayaa_pos/preview/sources/sample_product_source.dart';
import 'package:bayaa_pos/features/products/presentation/controllers/product_cubit.dart';
import 'package:bayaa_pos/features/inventory/presentation/controllers/stock_alerts_cubit.dart';
import 'package:bayaa_pos/features/invoices/presentation/controllers/invoice_cubit.dart';
import 'package:bayaa_pos/features/pos/presentation/sources/invoice_catalog_source.dart';
import 'package:bayaa_pos/features/inventory_summary/presentation/controllers/inventory_summary_cubit.dart';
import 'package:get_it/get_it.dart';

import 'package:bayaa_pos/features/notifications/presentation/controllers/notification_cubit.dart';
import 'package:bayaa_pos/preview/sources/sample_invoice_source.dart';

import 'package:bayaa_pos/preview/sources/store_preview_data.dart';
import 'package:bayaa_pos/preview/sources/sample_store_source.dart';
import 'package:bayaa_pos/features/settings/presentation/controllers/settings_cubit.dart';
import 'package:bayaa_pos/shared/localization/locale_provider.dart';

final getIt = GetIt.instance;

void setup() {
  // Core Services
  getIt.registerSingleton<LocaleProvider>(LocaleProvider());

  final userRepo = SampleUserSource();
  getIt.registerSingleton<UserDirectorySource>(userRepo);

  getIt.registerSingleton<UserCubit>(UserCubit(userRepository: userRepo));

  getIt.registerSingleton<ProductCubit>(
      ProductCubit(productRepositoryInt: SampleProductSource()));

  final salesRepo = SampleInvoiceSource();

  getIt.registerSingleton<InvoiceCatalogSource>(salesRepo);
  getIt.registerSingleton<SampleInvoiceSource>(salesRepo);

  getIt.registerSingleton<StockAlertsCubit>(
      StockAlertsCubit(productRepository: SampleProductSource()));

  getIt.registerSingleton<InvoiceCubit>(InvoiceCubit(salesRepo));

  getIt.registerSingleton<NotificationCubit>(NotificationCubit());

  getIt.registerFactory<InventorySummaryCubit>(() => InventorySummaryCubit());

  final storeInfoRepo = SampleStoreSource(
    dataSource: StorePreviewData(),
  );
  getIt.registerSingleton<SampleStoreSource>(storeInfoRepo);

  getIt.registerLazySingleton<SettingsCubit>(() => SettingsCubit(
        userCubit: getIt<UserCubit>(),
        storeRepository: storeInfoRepo,
      ));
}
