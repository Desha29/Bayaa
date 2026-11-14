import 'package:bayaa_pos/shared/widgets/charts/feature_insights_spec.dart';
import 'package:bayaa_pos/preview/branch_preview_controller.dart';

/// Chart display fixtures. They are not derived from operational records.
FeatureInsightsSpec featureChartExamples(String feature) {
  const trends = <String, List<double>>{
    'dashboard': [18, 24, 21, 32, 28, 39, 42],
    'sales': [12, 17, 15, 23, 19, 28, 31],
    'invoices': [15, 21, 18, 26, 24, 32, 36],
    'products': [45, 48, 42, 56, 53, 62, 68],
    'stock_alerts': [16, 12, 14, 10, 8, 6, 5],
    'stock_summary': [54, 58, 61, 57, 65, 68, 72],
    'reports': [24, 28, 31, 25, 36, 39, 45],
    'notifications': [18, 14, 16, 12, 10, 8, 5],
    'expenses': [8, 12, 10, 18, 15, 12, 16],
    'settings': [2, 3, 2, 4, 3, 4, 5],
    'customers': [12, 15, 14, 22, 21, 28, 32],
    'suppliers': [8, 12, 10, 14, 16, 18, 20],
    'purchases': [22, 18, 26, 24, 32, 28, 38],
    'purchase_returns': [9, 7, 8, 5, 6, 4, 3],
    'finance': [28, 32, 26, 38, 35, 44, 48],
    'warehouses': [52, 56, 54, 62, 65, 66, 68],
  };
  const titles = <String, List<String>>{
    'dashboard': ['Sales activity', 'نشاط المبيعات'],
    'sales': ['Checkout activity', 'نشاط نقاط البيع'],
    'invoices': ['Invoice activity', 'حركة الفواتير'],
    'products': ['Stock coverage', 'تغطية المخزون'],
    'stock_alerts': ['Stock alerts', 'تنبيهات المخزون'],
    'stock_summary': ['Inventory value trend', 'اتجاه قيمة المخزون'],
    'reports': ['Revenue trend', 'اتجاه الإيرادات'],
    'notifications': ['Alert volume', 'حجم التنبيهات'],
    'expenses': ['Expense trend', 'اتجاه المصروفات'],
    'settings': ['User access overview', 'نظرة على المستخدمين'],
    'customers': ['Customer activity', 'نشاط العملاء'],
    'suppliers': ['Supply activity', 'نشاط التوريد'],
    'purchases': ['Purchase volume', 'حجم المشتريات'],
    'purchase_returns': ['Return volume', 'حجم المرتجعات'],
    'finance': ['Cash movement', 'حركة النقدية'],
    'warehouses': ['Storage utilization', 'استخدام سعة التخزين'],
  };
  const distributions = <String, List<List<String>>>{
    'sales': [
      ['Cash', 'Wallet', 'Card'],
      ['نقدي', 'محفظة', 'بطاقة']
    ],
    'invoices': [
      ['Paid', 'Refund', 'Draft'],
      ['مدفوع', 'مرتجع', 'مسودة']
    ],
    'products': [
      ['Grocery', 'Dairy', 'Beverages'],
      ['بقالة', 'ألبان', 'مشروبات']
    ],
    'stock_alerts': [
      ['Low stock', 'Out of stock', 'Reviewed'],
      ['منخفض', 'نفد المخزون', 'تمت المراجعة']
    ],
    'stock_summary': [
      ['Grocery', 'Dairy', 'Beverages'],
      ['بقالة', 'ألبان', 'مشروبات']
    ],
    'notifications': [
      ['Urgent', 'Unread', 'Read'],
      ['عاجل', 'غير مقروء', 'مقروء']
    ],
    'expenses': [
      ['Rent', 'Utilities', 'Supplies'],
      ['إيجار', 'مرافق', 'مستلزمات']
    ],
    'settings': [
      ['Managers', 'Cashiers', 'Other'],
      ['مديرون', 'كاشير', 'أخرى']
    ],
    'customers': [
      ['Active', 'New', 'On hold'],
      ['نشط', 'جديد', 'موقوف']
    ],
    'suppliers': [
      ['Food', 'Dairy', 'Supplies'],
      ['أغذية', 'ألبان', 'مستلزمات']
    ],
    'purchases': [
      ['Received', 'Pending', 'Draft'],
      ['مستلم', 'قيد الانتظار', 'مسودة']
    ],
    'purchase_returns': [
      ['Quality', 'Damage', 'Other'],
      ['جودة', 'تلف', 'أخرى']
    ],
    'finance': [
      ['Cash', 'Bank', 'Wallet'],
      ['نقدي', 'بنك', 'محفظة']
    ],
    'warehouses': [
      ['Cairo', 'Giza', 'Alexandria'],
      ['القاهرة', 'الجيزة', 'الإسكندرية']
    ],
  };
  final title = titles[feature] ?? titles['dashboard']!;
  final labels = distributions[feature] ??
      const [
        ['Sales', 'Purchases', 'Expenses'],
        ['المبيعات', 'المشتريات', 'المصروفات']
      ];
  return FeatureInsightsSpec(
      trendTitle: title[0],
      trendTitleAr: title[1],
      distributionTitle: 'Distribution overview',
      distributionTitleAr: 'نظرة على التوزيع',
      trend: (trends[feature] ?? trends['dashboard']!)
          .map(
              (value) => value * BranchPreviewController.instance.previewFactor)
          .toList(),
      labels: labels[0],
      labelsAr: labels[1],
      distribution: const [52, 31, 17]);
}
