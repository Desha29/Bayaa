import 'package:bayaa_pos/preview/branch_preview_controller.dart';
import 'package:bayaa_pos/features/auth/presentation/models/user_view_data.dart';
import 'package:bayaa_pos/features/expenses/presentation/models/expense_view_data.dart';
import 'package:bayaa_pos/features/products/presentation/models/product_view_data.dart';
import 'package:bayaa_pos/features/pos/presentation/models/invoice_view_data.dart';
import 'package:bayaa_pos/features/settings/presentation/models/store_view_data.dart';
import 'package:bayaa_pos/features/inventory_summary/presentation/models/product_sales_view_data.dart';
import 'package:bayaa_pos/features/inventory_summary/presentation/models/inventory_category_view_data.dart';

/// The only data source in the UI showcase. Each getter returns fresh objects
/// so editing a form never changes the examples on another screen.
abstract final class PreviewData {
  static final today = DateUtilsPreview.today;

  static List<UserViewData> get users => [
        UserViewData(
            name: 'أحمد محمد',
            phone: '01000000001',
            username: 'demo',
            password: '',
            userType: PreviewRole.manager),
        UserViewData(
            name: 'سارة علي',
            phone: '01000000002',
            username: 'sara',
            password: '',
            userType: PreviewRole.cashier),
        UserViewData(
            name: 'عمر حسن',
            phone: '01000000003',
            username: 'omar',
            password: '',
            userType: PreviewRole.cashier),
      ];

  static StoreViewData get store => StoreViewData(
      name: BranchPreviewController.instance.isAll
          ? 'متجر بياع'
          : 'بياع · ${BranchPreviewController.instance.label(true)}',
      address: switch (BranchPreviewController.instance.activeId) {
        'giza' => 'شارع التحرير، الجيزة',
        'alexandria' => 'طريق الكورنيش، الإسكندرية',
        _ => 'شارع النصر، القاهرة'
      },
      phone: '01000000000',
      email: 'demo@example.com',
      vat: '123456789');

  static List<ProductViewData> get products => BranchPreviewController.instance
      .scope(_allProducts, (product) => product.barcode);

  static List<ProductViewData> get _allProducts => [
        _product('حليب كامل الدسم', '100001', 'ألبان', 45, 32, 24),
        _product('جبنة بيضاء', '100002', 'ألبان', 65, 48, 4),
        _product('زبادي طبيعي', '100003', 'ألبان', 15, 10, 0),
        _product('أرز مصري 1 كجم', '100004', 'بقالة', 38, 28, 72),
        _product('سكر أبيض 1 كجم', '100005', 'بقالة', 35, 25, 46),
        _product('زيت عباد الشمس', '100006', 'بقالة', 95, 75, 3),
        _product('مكرونة 400 جم', '100007', 'بقالة', 22, 15, 60),
        _product('قهوة عربية', '100008', 'مشروبات', 120, 85, 18),
        _product('شاي أسود', '100009', 'مشروبات', 55, 40, 30),
        _product('عصير برتقال', '100010', 'مشروبات', 30, 20, 0),
        _product('مياه معدنية', '100011', 'مشروبات', 10, 6, 96),
        _product('بسكويت بالشوكولاتة', '100012', 'حلويات', 18, 12, 35),
        _product('شوكولاتة بالحليب', '100013', 'حلويات', 40, 28, 2),
        _product('مناديل ورقية', '100014', 'منزلية', 25, 17, 40),
        _product('صابون سائل', '100015', 'منزلية', 60, 42, 20),
      ];

  static ProductViewData _product(String name, String barcode, String category,
          double price, double cost, int quantity) =>
      ProductViewData(
          name: name,
          barcode: barcode,
          category: category,
          price: price,
          minPrice: price - 2,
          wholesalePrice: cost,
          quantity: quantity,
          minQuantity: 8,
          imagePath: _productImage(barcode));

  static String _productImage(String barcode) {
    final photo = switch (barcode) {
      '100001' || '100002' || '100003' => 'photo-1563636619-e9143da7973b',
      '100008' || '100009' => 'photo-1447933601403-0c6688de566e',
      '100010' || '100011' => 'photo-1548839140-29a749e1cf4d',
      '100012' || '100013' => 'photo-1548907040-4d52baa860b4',
      _ => 'photo-1542838132-92c53300491e',
    };
    return 'https://images.unsplash.com/$photo?w=360&h=240&fit=crop&auto=format';
  }

  static List<String> get categories =>
      products.map((p) => p.category).toSet().toList();

  static Map<String, String> get productCategories => {
        for (final product in _allProducts) product.barcode: product.category,
      };

  static List<InvoiceViewData> get sales => BranchPreviewController.instance
      .scope(_allSales, (sale) => sale.refundOriginalInvoiceId ?? sale.id);

  static List<InvoiceViewData> get _allSales => List.generate(100, (i) {
        final day = i < 40 ? i ~/ 5 : 14 + ((i - 40) ~/ 5) * 30;
        final refund = i % 5 == 4;
        final fixtures = _allProducts;
        final p = fixtures[(refund ? i - 4 : i) % fixtures.length];
        final qty = refund ? 1 : 2;
        return InvoiceViewData(
            id: 'DEMO-${day + 1}${i % 5 + 1}',
            total: p.price * qty,
            items: qty,
            date: today
                .subtract(Duration(days: day))
                .add(Duration(hours: 10 + i % 5)),
            cashierName: users[i % users.length].name,
            cashierUsername: 'demo',
            invoiceTypeIndex: refund ? 1 : 0,
            refundOriginalInvoiceId: refund ? 'DEMO-${day + 1}1' : null,
            paymentMethod: i.isEven ? 'cash' : 'card',
            saleItems: [
              InvoiceItemViewData(
                  productId: p.barcode,
                  name: p.name,
                  price: p.price,
                  quantity: qty,
                  total: p.price * qty,
                  wholesalePrice: p.wholesalePrice,
                  refundedQuantity: i % 5 == 0 ? 1 : 0)
            ]);
      }).reversed.toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  static List<ExpenseViewData> get expenses => BranchPreviewController.instance
      .scope(_allExpenses, (expense) => expense.id);

  static List<ExpenseViewData> get _allExpenses => [
        ExpenseViewData(
            id: 'DEMO-EXP-1',
            title: 'إيجار المحل',
            amount: 3500,
            category: 'rent',
            date: today),
        ExpenseViewData(
            id: 'DEMO-EXP-2',
            title: 'فاتورة الكهرباء',
            amount: 650,
            category: 'utilities',
            date: today),
        ExpenseViewData(
            id: 'DEMO-EXP-3',
            title: 'مستلزمات تغليف',
            amount: 120,
            category: 'supplies',
            date: today),
        ExpenseViewData(
            id: 'DEMO-EXP-4',
            title: 'خدمة توصيل',
            amount: 85,
            category: 'General',
            date: today.subtract(const Duration(days: 1))),
      ];

  static List<InventoryCategoryViewData> get stockSummary =>
      categories.map((category) {
        final items = products.where((p) => p.category == category).toList();
        final cost =
            items.fold(0.0, (sum, p) => sum + p.quantity * p.wholesalePrice);
        return InventoryCategoryViewData(
            categoryName: category,
            productCount: items.length,
            totalQuantity: items.fold(0, (sum, p) => sum + p.quantity),
            totalSoldQuantity: 24,
            totalHistoricValue: cost + 1200,
            totalCurrentWholesaleValue: cost,
            totalMinSellValue:
                items.fold(0.0, (sum, p) => sum + p.quantity * p.minPrice),
            totalDefaultSellValue:
                items.fold(0.0, (sum, p) => sum + p.quantity * p.price),
            productDetails: items
                .map((p) => ProductSalesViewData(
                    productName: p.name,
                    barcode: p.barcode,
                    soldQuantity: 8,
                    refundedQuantity: 1))
                .toList());
      }).toList();
}

abstract final class DateUtilsPreview {
  static final today =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
}
