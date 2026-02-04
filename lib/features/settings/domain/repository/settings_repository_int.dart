
import 'package:dartz/dartz.dart';


import '../../../../core/error/failure.dart';
import '../../data/models/store_info_model.dart';

abstract class StoreInfoRepositoryInt {
  Future<Either<Failure, StoreInfo>> getStoreInfo();
  Future<Either<Failure, Unit>> saveStoreInfo(StoreInfo storeInfo);
  Future<Either<Failure, Unit>> deleteStoreInfo();
}
