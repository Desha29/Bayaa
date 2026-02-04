import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../domain/repository/settings_repository_int.dart';
import '../data_source/store_info_data_source.dart';
import '../models/store_info_model.dart';

class StoreInfoRepository implements StoreInfoRepositoryInt {
  final StoreInfoDataSource dataSource;

  StoreInfoRepository({required this.dataSource});

  @override
  Future<Either<Failure, StoreInfo>> getStoreInfo() async {
    try {
      final storeInfo = await dataSource.getStoreInfo();
      if (storeInfo != null) {
        return Right(storeInfo);
      } else {
        final defaultStore = dataSource.getDefaultStoreInfo();
        await dataSource.saveStoreInfo(defaultStore);
        return Right(defaultStore);
      }
    } catch (e) {
      return Left(CacheFailure('فشل في جلب معلومات المتجر: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveStoreInfo(StoreInfo storeInfo) async {
    try {
      await dataSource.saveStoreInfo(storeInfo);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('فشل في حفظ معلومات المتجر: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteStoreInfo() async {
    try {
      await dataSource.deleteStoreInfo();
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('فشل في حذف معلومات المتجر: ${e.toString()}'));
    }
  }
}
