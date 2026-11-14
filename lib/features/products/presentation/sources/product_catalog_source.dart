import 'package:bayaa_pos/features/products/presentation/models/product_view_data.dart';
import 'package:either_dart/either.dart';

import 'package:bayaa_pos/shared/foundation/preview_failure.dart';

abstract class ProductCatalogSource {
  Future<Either<Failure, List<ProductViewData>>> getAllProduct();
  Future<Either<Failure, List<ProductViewData>>> getProductsPaginated({
    required int page,
    required int pageSize,
    String? category,
    String? availability,
    String? searchQuery,
  });

  Future<Either<Failure, List<String>>> getAllCategory();
}
