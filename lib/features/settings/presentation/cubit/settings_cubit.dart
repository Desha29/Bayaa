import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crazy_phone_pos/features/auth/presentation/cubit/user_cubit.dart';
import '../../../auth/data/models/user_model.dart';
import '../../data/models/store_info_model.dart';
import '../../domain/repository/settings_repository_int.dart';
import 'settings_states.dart';

class SettingsCubit extends Cubit<SettingsStates> {
  SettingsCubit({
    required this.userCubit,
    required this.storeRepository,
  }) : super(SettingsInitial()) {
    loadStoreInfo();
  }

  final UserCubit userCubit;
  final StoreInfoRepositoryInt storeRepository;
  
  static SettingsCubit get(context) => BlocProvider.of(context);

  StoreInfo? _currentStoreInfo;
  StoreInfo? get currentStoreInfo => _currentStoreInfo;

  void loadStoreInfo() {
    emit(SettingsLoading());
    final result = storeRepository.getStoreInfo();
    
    result.fold(
      (failure) => emit(StoreInfoUpdateFailure(failure.message)),
      (storeInfo) {
        _currentStoreInfo = storeInfo;
        emit(StoreInfoLoaded(storeInfo));
      },
    );
  }

  void updateStoreInfo(Map<String, String> newStoreInfoMap) {
    emit(SettingsLoading());
    final newStoreInfo = StoreInfo.fromMap(newStoreInfoMap);
    final result = storeRepository.saveStoreInfo(newStoreInfo);
    
    result.fold(
      (failure) {
        emit(StoreInfoUpdateFailure(failure.message));
        if (_currentStoreInfo != null) {
          emit(StoreInfoLoaded(_currentStoreInfo!));
        }
      },
      (_) {
        _currentStoreInfo = newStoreInfo;
        emit(StoreInfoUpdateSuccess("تم حفظ معلومات المتجر بنجاح"));
        emit(StoreInfoLoaded(newStoreInfo));
      },
    );
  }

  String getCurrentUserName() {
    try {
      return userCubit.currentUser.name;
    } catch (e) {
      return 'غير معروف';
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
      return userCubit.currentUser.userType == UserType.manager; // Fixed
    } catch (e) {
      return false;
    }
  }
}
