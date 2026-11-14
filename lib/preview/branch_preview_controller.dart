import 'package:flutter/foundation.dart';

/// In-memory display scope for branch sample content. No storage or permissions.
class BranchPreviewController extends ChangeNotifier {
  BranchPreviewController._();
  static final instance = BranchPreviewController._();
  static const branchIds = ['all', 'cairo', 'giza', 'alexandria'];
  static const labelsEn = [
    'All branches',
    'Cairo · Main',
    'Giza · Retail',
    'Alexandria · Coast'
  ];
  static const labelsAr = [
    'كل الفروع',
    'القاهرة · الرئيسي',
    'الجيزة · التجزئة',
    'الإسكندرية · الساحل'
  ];
  String _activeId = 'all';
  final Map<String, Set<String>> _hidden = {};
  String get activeId => _activeId;
  bool get isAll => activeId == 'all';
  int get branchIndex => branchIds.indexOf(activeId) - 1;
  double get previewFactor => isAll ? 1 : [.42, .33, .25][branchIndex];
  String label(bool arabic) => labelFor(activeId, arabic);
  static String labelFor(String id, bool arabic) {
    final index = branchIds.indexOf(id);
    return index < 0 ? id : (arabic ? labelsAr : labelsEn)[index];
  }

  void select(String id) {
    if (!branchIds.contains(id) || id == activeId) return;
    _activeId = id;
    notifyListeners();
  }

  List<T> scope<T>(List<T> records, String Function(T) key) => isAll
      ? List<T>.from(records)
      : records
          .where((record) =>
              key(record).codeUnits.fold<int>(0, (sum, code) => sum + code) %
                  3 ==
              branchIndex)
          .toList();
  static const sections = <String, (String, String)>{
    'sales': ('Sales & invoices', 'المبيعات والفواتير'),
    'inventory': ('Products & inventory', 'المنتجات والمخزون'),
    'purchasing': ('Purchases & suppliers', 'المشتريات والموردون'),
    'customers': ('Customers', 'العملاء'),
    'finance': ('Finance & expenses', 'المالية والمصروفات'),
    'reports': ('Reports', 'التقارير'),
  };
  String? sectionFor(String module) => switch (module) {
        'sales' || 'invoices' => 'sales',
        'products' || 'stock_alerts' || 'stock_summary' => 'inventory',
        'purchases' || 'purchase_returns' || 'suppliers' => 'purchasing',
        'customers' => 'customers',
        'finance' || 'expenses' => 'finance',
        'reports' || 'notifications' => 'reports',
        _ => null,
      };
  bool sectionVisible(String section) =>
      !(_hidden[activeId]?.contains(section) ?? false);
  bool moduleVisible(String module) =>
      sectionFor(module) == null || sectionVisible(sectionFor(module)!);
  void setSectionVisible(String section, bool visible) {
    final hidden = _hidden.putIfAbsent(activeId, () => <String>{});
    visible ? hidden.remove(section) : hidden.add(section);
    notifyListeners();
  }
}
