import 'package:bayaa_pos/preview/data/preview_data.dart';
import 'package:bayaa_pos/features/settings/presentation/models/store_view_data.dart';

class StorePreviewData {
  Future<StoreViewData?> getStoreInfo() async => PreviewData.store;
  StoreViewData getDefaultStoreInfo() => PreviewData.store;

  Future<bool> hasStoreInfo() async => true;
}
