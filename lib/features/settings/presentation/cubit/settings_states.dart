// settings_states.dart

import '../../data/models/store_info_model.dart';

abstract class SettingsStates {}

class SettingsInitial extends SettingsStates {}

class SettingsLoading extends SettingsStates {}

class StoreInfoLoaded extends SettingsStates {
  final StoreInfo storeInfo;
  StoreInfoLoaded(this.storeInfo);
}

class StoreInfoUpdateSuccess extends SettingsStates {
  final String message;
  StoreInfoUpdateSuccess(this.message);
}

class StoreInfoUpdateFailure extends SettingsStates {
  final String message;
  StoreInfoUpdateFailure(this.message);
}
