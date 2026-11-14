// settings_states.dart

import 'package:bayaa_pos/features/settings/presentation/models/store_view_data.dart';

abstract class SettingsState {}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class StoreInfoLoaded extends SettingsState {
  final StoreViewData storeInfo;
  StoreInfoLoaded(this.storeInfo);
}

class StoreInfoUpdateSuccess extends SettingsState {
  final String message;
  StoreInfoUpdateSuccess(this.message);
}

class StoreInfoUpdateFailure extends SettingsState {
  final String message;
  StoreInfoUpdateFailure(this.message);
}
