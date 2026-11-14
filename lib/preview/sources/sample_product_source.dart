import 'package:either_dart/either.dart';
import 'package:bayaa_pos/shared/foundation/preview_failure.dart';
import 'package:bayaa_pos/preview/data/preview_data.dart';
import 'package:bayaa_pos/features/products/presentation/sources/product_catalog_source.dart';
import 'package:bayaa_pos/features/products/presentation/models/product_view_data.dart';

/// Read-only adapter for the existing product widgets.
class SampleProductSource implements ProductCatalogSource {
  @override
  Future<Either<Failure, List<ProductViewData>>> getAllProduct() async =>
      Right(PreviewData.products);
  @override
  Future<Either<Failure, List<ProductViewData>>> getProductsPaginated(
      {required int page,
      required int pageSize,
      String? category,
      String? availability,
      String? searchQuery}) async {
    final query = (searchQuery ?? '').trim().toLowerCase();
    final items = PreviewData.products.where((p) =>
        (category == null || category == '*' || p.category == category) &&
        (availability == null ||
            availability == '*' ||
            p.status == availability) &&
        (query.isEmpty ||
            p.name.toLowerCase().contains(query) ||
            p.barcode.contains(query)));
    return Right(items.skip(page * pageSize).take(pageSize).toList());
  }

  @override
  Future<Either<Failure, List<String>>> getAllCategory() async =>
      Right(PreviewData.categories);
}
