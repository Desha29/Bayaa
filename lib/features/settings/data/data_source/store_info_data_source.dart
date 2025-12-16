// store_info_data_source.dart
import 'package:hive/hive.dart';
import '../models/store_info_model.dart';

class StoreInfoDataSource {
  final Box<StoreInfo> _storeBox = Hive.box('storeBox');
  static const String _storeKey = 'store_info';

  void saveStoreInfo(StoreInfo storeInfo) {
    try {
      _storeBox.put(_storeKey, storeInfo);
    } on Exception {
      rethrow;
    }
  }

  StoreInfo? getStoreInfo() {
    try {
      return _storeBox.get(_storeKey);
    } on Exception {
      rethrow;
    }
  }

  void deleteStoreInfo() {
    try {
      _storeBox.delete(_storeKey);
    } on Exception {
      rethrow;
    }
  }

  bool hasStoreInfo() {
    return _storeBox.containsKey(_storeKey);
  }

  StoreInfo getDefaultStoreInfo() {
    return StoreInfo(
      name: 'Amr Store',
      phone: '01000000000',
      email: 'info@amrstore.com',
      address: "امام شارع الحجار - الخانكة - القليوبية",
      vat: '123456789',
    );
  }
}
