import 'package:dartz/dartz.dart';

import 'package:bayaa_pos/shared/foundation/preview_failure.dart';
import 'package:bayaa_pos/features/settings/presentation/models/store_view_data.dart';

abstract class StoreProfileSource {
  Future<Either<Failure, StoreViewData>> getStoreInfo();
}
