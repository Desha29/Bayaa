import 'package:bloc/bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/utils/hive_helper.dart';
import '../../../products/data/models/product_model.dart';
import '../../../sales/data/models/sale_model.dart';
import '../../data/models/stock_summary_category_model.dart';
import '../../data/models/product_sales_detail.dart';
import 'stock_summary_state.dart';

class StockSummaryCubit extends Cubit<StockSummaryState> {
  StockSummaryCubit() : super(StockSummaryInitial());

  // Listen to changes in boxes to auto-update
  void init() {
    loadData();
    HiveHelper.productsBox.listenable().addListener(loadData);
    HiveHelper.salesBox.listenable().addListener(loadData);
  }

  @override
  Future<void> close() {
    HiveHelper.productsBox.listenable().removeListener(loadData);
    HiveHelper.salesBox.listenable().removeListener(loadData);
    return super.close();
  }

  Future<void> loadData() async {
    if (isClosed) return;
    emit(StockSummaryLoading());
    try {
      final products = HiveHelper.productsBox.values.toList();
      final salesBox = HiveHelper.salesBox;

      // Maps to hold aggregations
      final Map<String, List<Product>> categoryProducts = {};
      final Map<String, double> categoryHistoricSoldValue = {};
      final Map<String, int> categorySoldQty = {};
      final Map<String, Map<String, ProductSalesDetail>> categoryProductDetails = {}; // NEW: Product-level details

      // 1. Group Current Products by Category
      for (var product in products) {
        if (!categoryProducts.containsKey(product.category)) {
          categoryProducts[product.category] = [];
        }
        categoryProducts[product.category]!.add(product);
      }


      
      final saleKeys = salesBox.keys;
      for (var key in saleKeys) {
        final Sale? sale = await salesBox.get(key);
        if (sale == null) continue;
        
        // If it's a Sale (Index 0)
        if (sale.invoiceTypeIndex == 0) {
          for (var item in sale.saleItems) {
            // Find category for this sold item
            String category = 'المحذوفة'; // Default to Deleted
            String productName = item.name;
            final product = products.firstWhere(
              (p) => p.barcode == item.productId, 
              orElse: () => Product(
                name: '', barcode: '', price: 0, minPrice: 0, wholesalePrice: 0, 
                quantity: 0, minQuantity: 0, category: 'المحذوفة'
              )
            );
            
            if (product.barcode.isNotEmpty) {
               category = product.category;
               productName = product.name;
            }

       
            if (!categoryProductDetails.containsKey(category)) {
              categoryProductDetails[category] = {};
            }
            
            final productKey = item.productId;
            if (!categoryProductDetails[category]!.containsKey(productKey)) {
              categoryProductDetails[category]![productKey] = ProductSalesDetail(
                productName: productName,
                barcode: item.productId,
                soldQuantity: 0,
                refundedQuantity: 0,
              );
            }
            
            // Update sold and refunded quantities
            final existing = categoryProductDetails[category]![productKey]!;
            categoryProductDetails[category]![productKey] = ProductSalesDetail(
              productName: existing.productName,
              barcode: existing.barcode,
              soldQuantity: existing.soldQuantity + item.quantity,
              refundedQuantity: existing.refundedQuantity + item.refundedQuantity,
            );

            // Net Sold Qty for this item transaction
            final netSoldQty = item.quantity - item.refundedQuantity;
            
            if (netSoldQty > 0) {
              // Accumulate Historic Value of Sold Items
              final soldValue = netSoldQty * item.wholesalePrice;
              
              categoryHistoricSoldValue[category] = 
                  (categoryHistoricSoldValue[category] ?? 0) + soldValue;
                  
               categorySoldQty[category] = 
                   (categorySoldQty[category] ?? 0) + netSoldQty;
            }
          }
        }
      }

      // 3. Construct Category Models
      final List<StockSummaryCategoryModel> summaryList = [];
      
      // Get all unique categories (from current products + from sales history)
      final allCategories = {...categoryProducts.keys, ...categoryHistoricSoldValue.keys};

      for (var category in allCategories) {
        final productsInCategory = categoryProducts[category] ?? [];
        
        // Current Stock Calculations
        int currentQty = 0;
        double currentWholesaleValue = 0;
        double currentMinSellValue = 0;
        double currentDefaultSellValue = 0;
        double historicFromStock = 0;

        for (var p in productsInCategory) {
          currentQty += p.quantity;
          currentWholesaleValue += (p.quantity * p.wholesalePrice);
          currentMinSellValue += (p.quantity * p.minPrice);
          currentDefaultSellValue += (p.quantity * p.price);
          historicFromStock += (p.quantity * p.wholesalePrice);
        }

        // Historic Calculations
        // Total Historic = Value of Current Stock + Value of Net Sold Items
        final historicFromSold = categoryHistoricSoldValue[category] ?? 0;
        final totalHistoricValue = historicFromStock + historicFromSold;

        final productDetailsList = categoryProductDetails[category]?.values.toList() ?? [];
        
        summaryList.add(StockSummaryCategoryModel(
          categoryName: category,
          productCount: productsInCategory.length,
          totalQuantity: currentQty,
          totalSoldQuantity: categorySoldQty[category] ?? 0,
          totalHistoricValue: totalHistoricValue,
          totalCurrentWholesaleValue: currentWholesaleValue,
          totalMinSellValue: currentMinSellValue,
          totalDefaultSellValue: currentDefaultSellValue,
          isDeletedCategory: category == 'المحذوفة',
          productDetails: productDetailsList, 
        ));
      }

      // 4. Calculate Grand Totals
      double grandHistoric = 0;
      double grandCurrent = 0;
      double grandExpectedProfit = 0;

      for (var s in summaryList) {
        grandHistoric += s.totalHistoricValue;
        grandCurrent += s.totalCurrentWholesaleValue;
        grandExpectedProfit += s.expectedProfit;
      }

      if (!isClosed) {
        emit(StockSummaryLoaded(
          categories: summaryList,
          totalStoreHistoricValue: grandHistoric,
          totalStoreCurrentValue: grandCurrent,
          totalExpectedProfit: grandExpectedProfit,
        ));
      }

    } catch (e) {
      if (!isClosed) emit(StockSummaryError("فشل في حساب الملخص: $e"));
    }
  }
}
