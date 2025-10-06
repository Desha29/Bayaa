// store_info_repository_int.dart


import 'package:dartz/dartz.dart';


import '../../../../core/error/failure.dart';
import '../../data/models/store_info_model.dart';

abstract class StoreInfoRepositoryInt {
  Either<Failure, StoreInfo> getStoreInfo();
  Either<Failure, Unit> saveStoreInfo(StoreInfo storeInfo);
  Either<Failure, Unit> deleteStoreInfo();
}
