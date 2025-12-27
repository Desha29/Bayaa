import 'package:dartz/dartz.dart';
import '../../../core/error/failure.dart';
import '../../sales/domain/sales_repository.dart';

/// Represents an item that can be refunded with calculated quantities
class RefundableItem {
  final String productId;
  final String productName;
  final int originalQuantity;
  final int refundedQuantity;
  final int remainingQuantity;
  final double unitPrice;
  final double wholesalePrice;

  RefundableItem({
    required this.productId,
    required this.productName,
    required this.originalQuantity,
    required this.refundedQuantity,
    required this.unitPrice,
    required this.wholesalePrice,
  }) : remainingQuantity = originalQuantity - refundedQuantity;

  bool get canBeRefunded => remainingQuantity > 0;
  double get totalRefundValue => unitPrice * remainingQuantity;
}

/// Service for calculating refund-related data
class RefundCalculationService {
  final SalesRepository repository;

  RefundCalculationService(this.repository);

  /// Get total refunded quantities for each product in an invoice
  Future<Either<Failure, Map<String, int>>> getRefundedQuantities(
      String originalInvoiceId) async {
    final refundsResult =
        await repository.getRefundsForInvoice(originalInvoiceId);

    return refundsResult.fold(
      (failure) => Left(failure),
      (refunds) {
        final Map<String, int> refundedQuantities = {};

        for (final refund in refunds) {
          for (final item in refund.saleItems) {
            refundedQuantities[item.productId] =
                ((refundedQuantities[item.productId] ?? 0) + item.quantity)
                    .toInt();
          }
        }

        return Right(refundedQuantities);
      },
    );
  }

  /// Check if an invoice has been fully refunded
  Future<Either<Failure, bool>> isFullyRefunded(String invoiceId) async {
    final refundableItemsResult = await getRefundableItems(invoiceId);

    return refundableItemsResult.fold(
      (failure) => Left(failure),
      (items) => Right(items.every((item) => item.remainingQuantity == 0)),
    );
  }

  /// Get list of refundable items with remaining quantities
  Future<Either<Failure, List<RefundableItem>>> getRefundableItems(
      String invoiceId) async {
    // Get the original invoice
    final salesResult = await repository.getRecentSales(limit: 10000);

    return salesResult.fold(
      (failure) => Left(failure),
      (allSales) async {
        final originalSale = allSales.firstWhere(
          (s) => s.id == invoiceId,
          orElse: () => throw Exception('Invoice not found'),
        );

        if (originalSale.isRefund) {
          return Left(CacheFailure('Cannot refund a refund invoice'));
        }

        // Get refunded quantities
        // We now prioritize the stored refundedQuantity in SaleItem
        // to handle cases where refund invoices might be deleted

        return Right(originalSale.saleItems.map((item) {
          return RefundableItem(
            productId: item.productId,
            productName: item.name,
            originalQuantity: item.quantity,
            refundedQuantity: item.refundedQuantity,
            unitPrice: item.price,
            wholesalePrice: item.wholesalePrice,
          );
        }).toList());
      },
    );
  }
}
