// lib/features/sales/domain/sales_repository.dart
import 'package:dartz/dartz.dart';
import 'package:bayaa_pos/shared/foundation/preview_failure.dart';
import 'package:bayaa_pos/features/products/presentation/models/product_view_data.dart';
import 'package:bayaa_pos/features/pos/presentation/models/invoice_view_data.dart';

abstract class InvoiceCatalogSource {
  Future<Either<Failure, ProductViewData?>> findProductByBarcode(
      String barcode);
  Future<Either<Failure, List<ProductViewData>>> getAllProducts();
  Future<Either<Failure, List<InvoiceViewData>>> getAllSales();

  Future<Either<Failure, List<InvoiceViewData>>> getRecentSales({
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<Either<Failure, List<InvoiceViewData>>> getRefundsForInvoice(
      String originalInvoiceId);

  // NEW: Method to create sale with cashier info
}
