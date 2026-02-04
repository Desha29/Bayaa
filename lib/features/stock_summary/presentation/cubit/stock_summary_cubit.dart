import 'package:bloc/bloc.dart';
import 'package:crazy_phone_pos/core/data/services/persistence_initializer.dart';
import '../../data/models/stock_summary_category_model.dart';
import '../../data/models/product_sales_detail.dart';
import 'stock_summary_state.dart';

class StockSummaryCubit extends Cubit<StockSummaryState> {
  StockSummaryCubit() : super(StockSummaryInitial());

  // Removed Hive listeners
  void init() {
    loadData();
  }

  @override
  Future<void> close() {
    return super.close();
  }

  Future<void> loadData() async {
    if (isClosed) return;
    emit(StockSummaryLoading());
    try {
      print('📊 === STOCK SUMMARY: Loading Data (SQLite) ===');
      
      final db = PersistenceInitializer.persistenceManager!.sqliteManager;
      
      // 1. Query Current Stock Grouped by Category
      // Group by category_id directly
      final stockResults = await db.database.rawQuery('''
        SELECT 
          category_id,
          COUNT(*) as product_count,
          SUM(stock) as total_quantity,
          SUM(stock * wholesale_price) as wholesale_value,
          SUM(stock * min_price) as min_sell_value,
          SUM(stock * price) as default_sell_value
        FROM products
        WHERE is_active = 1
        GROUP BY category_id
      ''');

      // 2. Query Sales History Grouped by Category & Product
      // Join sales to filter out refunds (is_refund = 0)
      // Join products to get category_id. 
      // Handle deleted products (p.category_id IS NULL) -> likely category deleted or hard deleted.
      final salesResults = await db.database.rawQuery('''
        SELECT 
          p.category_id,
          si.product_id,
          si.product_name,
          si.product_barcode,
          SUM(si.quantity) as sold_qty,
          SUM(si.refunded_quantity) as refunded_qty,
          SUM((si.quantity - si.refunded_quantity) * si.wholesale_price) as total_wholesale_cost
        FROM sale_items si
        JOIN sales s ON si.sale_id = s.id
        LEFT JOIN products p ON si.product_id = p.id
        WHERE s.is_refund = 0
        GROUP BY p.category_id, si.product_id
      ''');

      // 3. Process & Merge Data
      final Map<String, StockSummaryCategoryModel> categoryMap = {};

      // Process Stock Data
      for (var row in stockResults) {
        final categoryId = row['category_id'] as String? ?? 'عام';
        
        categoryMap[categoryId] = StockSummaryCategoryModel(
          categoryName: categoryId, // We use ID as name based on schema
          productCount: row['product_count'] as int,
          totalQuantity: (row['total_quantity'] as num).toInt(),
          totalCurrentWholesaleValue: row['wholesale_value'] as double? ?? 0.0,
          totalMinSellValue: row['min_sell_value'] as double? ?? 0.0,
          totalDefaultSellValue: row['default_sell_value'] as double? ?? 0.0,
          // Initialize sales fields to 0, will update next
          totalSoldQuantity: 0,
          totalHistoricValue: 0, // Will add stock value later
          isDeletedCategory: false,
          productDetails: [],
        );
      }

      // Process Sales Data
      for (var row in salesResults) {
        var categoryId = row['category_id'] as String?;
        if (categoryId == null) {
          categoryId = 'المحذوفة';
        }
        
        if (!categoryMap.containsKey(categoryId)) {
           // Category exists in sales but not in current active products (maybe deleted category or no active products)
           categoryMap[categoryId] = StockSummaryCategoryModel(
             categoryName: categoryId,
             productCount: 0,
             totalQuantity: 0,
             totalCurrentWholesaleValue: 0,
             totalMinSellValue: 0,
             totalDefaultSellValue: 0,
             totalSoldQuantity: 0,
             totalHistoricValue: 0,
             isDeletedCategory: categoryId == 'المحذوفة',
             productDetails: [],
           );
        }

        final model = categoryMap[categoryId]!;
        final soldQty = (row['sold_qty'] as num).toInt();
        final refundedQty = (row['refunded_qty'] as num).toInt();
        final netSoldQty = soldQty - refundedQty;
        final wholesaleCost = row['total_wholesale_cost'] as double? ?? 0.0;

        // Update Model Totals
        // Note: totalHistoricValue = Current Stock Value + Net Sold Value
        // We will sum Current Stock Value at the end. Here we add Net Sold Value.
        
        // Wait, totalHistoricValue logic in original code:
        // totalHistoricValue = historicFromStock (current stock * wholesale) + historicFromSold (sold * wholesale)
        
        // Update product details
        final detail = ProductSalesDetail(
          productName: row['product_name'] as String,
          barcode: row['product_barcode'] as String? ?? row['product_id'] as String,
          soldQuantity: soldQty,
          refundedQuantity: refundedQty,
        );
        
        // We need to replace the model with updated values since it's immutable-ish or just update props?
        // StockSummaryCategoryModel fields are final. We need to reconstruct or make them mutable?
        // They are final. So we need to accumulate data in a temp structure or copyWith.
        // Let's assume we can't easily change the model structure.
        // Better strategy: Accumulate in Maps first, then build models.
      }
      
      // RESTART STRATEGY: Accumulate in Maps
      final Map<String, List<ProductSalesDetail>> catDetails = {};
      final Map<String, int> catSoldQty = {};
      final Map<String, double> catSoldValue = {};
      
      for (var row in salesResults) {
        var categoryId = row['category_id'] as String?;
        if (categoryId == null) categoryId = 'المحذوفة';
        
        final soldQty = (row['sold_qty'] as num).toInt();
        final refundedQty = (row['refunded_qty'] as num).toInt();
        final netSoldQty = soldQty - refundedQty;
        final wholesaleCost = row['total_wholesale_cost'] as double? ?? 0.0;

        catSoldQty[categoryId] = (catSoldQty[categoryId] ?? 0) + netSoldQty;
        catSoldValue[categoryId] = (catSoldValue[categoryId] ?? 0) + wholesaleCost;
        
        if (!catDetails.containsKey(categoryId)) {
          catDetails[categoryId] = [];
        }
        
        catDetails[categoryId]!.add(ProductSalesDetail(
          productName: row['product_name'] as String,
          barcode: row['product_barcode'] as String? ?? row['product_id'] as String,
          soldQuantity: soldQty,
          refundedQuantity: refundedQty,
        ));
      }

      final List<StockSummaryCategoryModel> summaryList = [];
      // Union of all categories
      final allCats = {...categoryMap.keys, ...catDetails.keys}; // categoryMap keys from Stock query
      
      // Stock Query Map (from Step 1) -> we need to access row data.
      // Let's re-map stockResults to a Map for easier access
      final stockDataMap = {
        for (var r in stockResults) 
          (r['category_id'] as String? ?? 'عام') : r
      };

      for (var cat in allCats) {
        final stockRow = stockDataMap[cat];
        final currentQty = stockRow != null ? (stockRow['total_quantity'] as num).toInt() : 0;
        final currentWholesale = stockRow != null ? (stockRow['wholesale_value'] as double? ?? 0.0) : 0.0;
        final minSell = stockRow != null ? (stockRow['min_sell_value'] as double? ?? 0.0) : 0.0;
        final defaultSell = stockRow != null ? (stockRow['default_sell_value'] as double? ?? 0.0) : 0.0;
        final productCount = stockRow != null ? (stockRow['product_count'] as int) : 0;
        
        final soldVal = catSoldValue[cat] ?? 0.0;
        final historicTotal = currentWholesale + soldVal;
        
        summaryList.add(StockSummaryCategoryModel(
          categoryName: cat,
          productCount: productCount,
          totalQuantity: currentQty,
          totalSoldQuantity: catSoldQty[cat] ?? 0,
          totalHistoricValue: historicTotal,
          totalCurrentWholesaleValue: currentWholesale,
          totalMinSellValue: minSell,
          totalDefaultSellValue: defaultSell,
          isDeletedCategory: cat == 'المحذوفة',
          productDetails: catDetails[cat] ?? [],
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

      print('  💰 Grand Total Historic Value: ${grandHistoric.toStringAsFixed(2)}');
      print('  💵 Grand Total Current Value: ${grandCurrent.toStringAsFixed(2)}');
      print('  ✅ Stock summary loaded successfully');

      if (!isClosed) {
        emit(StockSummaryLoaded(
          categories: summaryList,
          totalStoreHistoricValue: grandHistoric,
          totalStoreCurrentValue: grandCurrent,
          totalExpectedProfit: grandExpectedProfit,
        ));
      }

    } catch (e) {
      print('  ❌ Stock summary failed: $e');
      if (!isClosed) emit(StockSummaryError("فشل في حساب الملخص: $e"));
    }
  }
}
