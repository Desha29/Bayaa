import 'package:dartz/dartz.dart';
import 'package:bayaa_pos/shared/foundation/preview_failure.dart';
import 'package:bayaa_pos/preview/data/preview_data.dart';
import 'package:bayaa_pos/features/products/presentation/models/product_view_data.dart';
import 'package:bayaa_pos/features/pos/presentation/sources/invoice_catalog_source.dart';
import 'package:bayaa_pos/features/pos/presentation/models/invoice_view_data.dart';

/// Supplies sample invoices and product choices; never writes transactions.
class SampleInvoiceSource implements InvoiceCatalogSource {
  @override
  Future<Either<Failure, ProductViewData?>> findProductByBarcode(
      String barcode) async {
    final matches = PreviewData.products.where((p) => p.barcode == barcode);
    return Right(matches.isEmpty ? null : matches.first);
  }

  @override
  Future<Either<Failure, List<ProductViewData>>> getAllProducts() async =>
      Right(PreviewData.products);
  @override
  Future<Either<Failure, List<InvoiceViewData>>> getAllSales() async =>
      Right(PreviewData.sales);
  @override
  Future<Either<Failure, List<InvoiceViewData>>> getRecentSales(
          {int limit = 10, DateTime? startDate, DateTime? endDate}) async =>
      Right(PreviewData.sales
          .where((s) =>
              (startDate == null || !s.date.isBefore(startDate)) &&
              (endDate == null || !s.date.isAfter(endDate)))
          .take(limit)
          .toList());
  @override
  Future<Either<Failure, List<InvoiceViewData>>> getRefundsForInvoice(
          String originalInvoiceId) async =>
      Right(PreviewData.sales
          .where((s) => s.refundOriginalInvoiceId == originalInvoiceId)
          .toList());
}
