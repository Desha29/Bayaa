import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bayaa_pos/features/auth/presentation/controllers/user_cubit.dart';
import 'package:bayaa_pos/features/auth/presentation/models/user_view_data.dart';
import 'package:bayaa_pos/features/settings/presentation/models/store_view_data.dart';
import 'package:bayaa_pos/features/settings/presentation/sources/store_profile_source.dart';
import 'package:bayaa_pos/features/settings/presentation/controllers/settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({
    required this.userCubit,
    required this.storeRepository,
  }) : super(SettingsInitial()) {
    loadStoreInfo();
  }

  final UserCubit userCubit;
  final StoreProfileSource storeRepository;

  static SettingsCubit get(context) => BlocProvider.of(context);

  StoreViewData? _currentStoreInfo;
  StoreViewData? get currentStoreInfo => _currentStoreInfo;

  Future<void> loadStoreInfo() async {
    emit(SettingsLoading());
    final result = await storeRepository.getStoreInfo();

    result.fold(
      (failure) => emit(StoreInfoUpdateFailure(failure.message)),
      (storeInfo) {
        _currentStoreInfo = storeInfo;
        emit(StoreInfoLoaded(storeInfo));
      },
    );
  }

  String getCurrentUserName() {
    try {
      return userCubit.currentUser.name;
    } catch (e) {
      return 'unknownUser';
    }
  }

  String getCurrentUserType() {
    try {
      return userCubit.currentUser.userType.name;
    } catch (e) {
      return 'cashier';
    }
  }

  bool isAdmin() {
    try {
      return userCubit.currentUser.userType == PreviewRole.manager; // Fixed
    } catch (e) {
      return false;
    }
  }
}
