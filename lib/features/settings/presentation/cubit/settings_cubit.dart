import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crazy_phone_pos/features/auth/presentation/cubit/user_cubit.dart';
import '../../../auth/data/models/user_model.dart';
import '../../data/models/store_info_model.dart';
import '../../domain/repository/settings_repository_int.dart';
import 'settings_states.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/services/activity_logger.dart';
import '../../../../core/data/models/activity_log.dart';

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

  Future<void> updateStoreInfo(Map<String, String> newStoreInfoMap) async {
    emit(SettingsLoading());
    final newStoreInfo = StoreInfo.fromMap(newStoreInfoMap);
    final result = await storeRepository.saveStoreInfo(newStoreInfo);
    
    result.fold(
      (failure) {
        emit(StoreInfoUpdateFailure(failure.message));
        if (_currentStoreInfo != null) {
          emit(StoreInfoLoaded(_currentStoreInfo!));
        }
      },
      (_) {
        _currentStoreInfo = newStoreInfo;
        
        // Log activity
        getIt<ActivityLogger>().logActivity(
          type: ActivityType.userUpdate, // Reusing userUpdate or create storeUpdate type? userUpdate is close enough for settings
          description: 'تحديث معلومات المتجر',
          userName: userCubit.currentUser.name,
        );
        
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
