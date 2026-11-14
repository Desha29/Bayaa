import 'package:dartz/dartz.dart';
import 'package:bayaa_pos/shared/foundation/preview_failure.dart';
import 'package:bayaa_pos/features/settings/presentation/sources/store_profile_source.dart';
import 'package:bayaa_pos/preview/sources/store_preview_data.dart';
import 'package:bayaa_pos/features/settings/presentation/models/store_view_data.dart';

class SampleStoreSource implements StoreProfileSource {
  const SampleStoreSource({required this.dataSource});
  final StorePreviewData dataSource;
  @override
  Future<Either<Failure, StoreViewData>> getStoreInfo() async => Right(
      (await dataSource.getStoreInfo()) ?? dataSource.getDefaultStoreInfo());
}
