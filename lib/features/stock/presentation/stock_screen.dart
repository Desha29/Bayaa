import 'package:crazy_phone_pos/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Product {
  String code;
  String name;
  int quantity;
  int min;
  String lastRestock;

  Product({
    required this.code,
    required this.name,
    required this.quantity,
    required this.min,
    required this.lastRestock,
  });

  String get status {
    if (quantity == 0) return 'غير متوفر';
    if (quantity < min) return 'مخزون منخفض';
    return 'متوفر';
  }

  String get priority {
    if (quantity == 0) return 'عاجل جداً';
    final diff = min - quantity;
    if (diff >= 3) return 'عاجل';
    if (diff == 1 || diff == 2) return 'متوسط';
    return 'منخفض';
  }
}

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  List<Product> products = [
    Product(
      code: 'SGS23',
      name: 'سامسونج جالاكسي S23',
      quantity: 3,
      min: 5,
      lastRestock: '12/07/2025',
    ),
    Product(
      code: 'IP13',
      name: 'آيفون 13',
      quantity: 0,
      min: 3,
      lastRestock: '12/07/2025',
    ),
    Product(
      code: 'HWP40',
      name: 'هواوي P40 لايت',
      quantity: 1,
      min: 4,
      lastRestock: '14/01/2024',
    ),
    Product(
      code: 'XM12',
      name: 'شاومي ريدمي نوت 12',
      quantity: 0,
      min: 6,
      lastRestock: '16/01/2024',
    ),
    Product(
      code: 'OPF5',
      name: 'أوبو فايند X5',
      quantity: 2,
      min: 5,
      lastRestock: '13/01/2024',
    ),
  ];

  String filter = 'all';

  int get totalCount => products.length;
  int get outOfStockCount => products.where((p) => p.quantity == 0).length;
  int get lowStockCount =>
      products.where((p) => p.quantity > 0 && p.quantity < p.min).length;

  void _openRestockDialog(int index) async {
    await showDialog(
      context: context,
      builder: (context) {
        final product = products[index];
        final controller = TextEditingController();
        int after = product.quantity;
        String? error;

        return StatefulBuilder(
          builder: (context, setState) {
            void computeAfter() {
              final v = int.tryParse(controller.text);
              if (v == null) {
                setState(() {
                  after = product.quantity;
                  error = null;
                });
                return;
              }
              setState(() {
                after = product.quantity + v;
                error = null;
              });
            }

            return Dialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(width: 1),
                          Text(
                            'إعادة تخزين المنتج',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'الكمية الحالية: ${product.quantity}',
                                  ),
                                ),
                                Expanded(
                                  child: Text('الحد الأدنى: ${product.min}'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'الكمية المطلوبة: ${(product.min - product.quantity) > 0 ? (product.min - product.quantity).toString() : '0'}',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'كمية إعادة التخزين',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          hintText: 'أدخل الكمية',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          errorText: error,
                        ),
                        onChanged: (_) => computeAfter(),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'الكمية بعد التخزين:',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            after.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                final v = int.tryParse(controller.text ?? '');
                                if (v == null || v <= 0) {
                                  setState(() {
                                    error =
                                        'الرجاء إدخال كمية صحيحة أكبر من صفر';
                                  });
                                  return;
                                }
                                Navigator.of(
                                  context,
                                ).pop({'quantityToAdd': v, 'index': index});
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                              ),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Text('تأكيد إعادة التخزين'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 6,
                              ),
                              child: Text('إلغاء'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).then((res) {
      if (res is Map && res.containsKey('quantityToAdd')) {
        final q = res['quantityToAdd'] as int;
        final idx = res['index'] as int;
        setState(() {
          products[idx].quantity += q;
          final now = DateTime.now();
          products[idx].lastRestock =
              '${now.year}/${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}';
        });
      }
    });
  }

  Widget _buildMobileCards(List<Product> filtered) {
    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final product = filtered[index];
        final isOut = product.quantity == 0;
        final isLow = product.quantity > 0 && product.quantity < product.min;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${product.min} :الحد الأدنى'),
                  Text('${product.code} :الكود'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text('الكمية الحالية: '),
                      Text(
                        product.quantity.toString(),
                        style: TextStyle(
                          color: isOut
                              ? const Color(0xFFEF4444)
                              : (isLow
                                    ? const Color(0xFFF59E0B)
                                    : const Color(0xFF10B981)),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text('${product.lastRestock} :آخر تخزين'),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _statusChip(isOut, isLow),
                      const SizedBox(width: 8),
                      _priorityChip(product.priority),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      final origIndex = products.indexWhere(
                        (p) => p.code == product.code,
                      );
                      if (origIndex >= 0) _openRestockDialog(origIndex);
                    },
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('إعادة التخزين'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Product> filtered = products.where((p) {
      if (filter == 'all') return true;
      if (filter == 'low') return (p.quantity > 0 && p.quantity < p.min);
      if (filter == 'out') return p.quantity == 0;
      return true;
    }).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth >= 900;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'المنتجات الناقصة',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1A1A1A),
                                fontSize: 32,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'متابعة المنتجات التي تحتاج إعادة تخزين',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Summary Cards
                    if (isDesktop)
                      Row(
                        children: [
                          Expanded(
                            child: _summaryCard(
                              color: const Color(0xFF3B82F6),
                              icon: Icons.filter_list,
                              title: 'إجمالي المنتجات',
                              value: totalCount.toString(),
                              subtitle: 'منتج يحتاج متابعة',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _summaryCard(
                              color: const Color(0xFFEF4444),
                              icon: Icons.cancel_outlined,
                              title: 'غير متوفر',
                              value: outOfStockCount.toString(),
                              subtitle: 'منتج نفذ من المخزون',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _summaryCard(
                              color: const Color(0xFFF59E0B),
                              icon: Icons.warning_amber_rounded,
                              title: 'مخزون منخفض',
                              value: lowStockCount.toString(),
                              subtitle: 'منتج يحتاج إعادة تخزين',
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          _summaryCard(
                            color: const Color(0xFF3B82F6),
                            icon: Icons.filter_list,
                            title: 'إجمالي المنتجات',
                            value: totalCount.toString(),
                            subtitle: 'منتج يحتاج متابعة',
                          ),
                          const SizedBox(height: 16),
                          _summaryCard(
                            color: const Color(0xFFEF4444),
                            icon: Icons.cancel_outlined,
                            title: 'غير متوفر',
                            value: outOfStockCount.toString(),
                            subtitle: 'منتج نفذ من المخزون',
                          ),
                          const SizedBox(height: 16),
                          _summaryCard(
                            color: const Color(0xFFF59E0B),
                            icon: Icons.warning_amber_rounded,
                            title: 'مخزون منخفض',
                            value: lowStockCount.toString(),
                            subtitle: 'منتج يحتاج إعادة تخزين',
                          ),
                        ],
                      ),

                    const SizedBox(height: 32),

                    // Filter Buttons
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppColors.borderColor),
                      ),
                      color: AppColors.surfaceColor,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: isDesktop
                              ? MediaQuery.of(context).size.width / 3.5
                              : 16,
                        ),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _filterButton(
                              'جميع المنتجات',
                              '($totalCount)',
                              filter == 'all',
                              const Color(0xFF06B6D4),
                              () => setState(() => filter = 'all'),
                            ),
                            _filterButton(
                              'مخزون منخفض',
                              '($lowStockCount)',
                              filter == 'low',
                              const Color(0xFFF59E0B),
                              () => setState(() => filter = 'low'),
                            ),
                            _filterButton(
                              'غير متوفر',
                              '($outOfStockCount)',
                              filter == 'out',
                              const Color(0xFFEF4444),
                              () => setState(() => filter = 'out'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Table Header
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: const Color(0xFFF59E0B),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'المنتجات التي تحتاج إعادة تخزين (${filtered.length})',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Data Table/Cards - Expanded to fill remaining space
                    Expanded(
                      child: isDesktop
                          ? _buildDataTable(filtered, context)
                          : _buildMobileCards(filtered),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _summaryCard({
    required Color color,
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(12),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(fontSize: 12, color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // زر الفلترة العلوي
  Widget _filterButton(
    String text,
    String count,
    bool isSelected,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? color : Colors.white,
        foregroundColor: isSelected ? Colors.white : const Color(0xFF374151),
        elevation: 0,
        side: BorderSide(
          color: isSelected ? color : const Color(0xFFE5E7EB),
          width: 1,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white.withOpacity(0.2)
                  : color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Chip حالة المنتج
  Widget _statusChip(bool isOut, bool isLow) {
    if (isOut) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'غير متوفر',
          style: TextStyle(color: Color(0xFFDC2626), fontSize: 13),
        ),
      );
    } else if (isLow) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.yellow.shade50,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'مخزون منخفض',
          style: TextStyle(color: Color(0xFFCA8A04), fontSize: 13),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'متوفر',
          style: TextStyle(color: Color(0xFF059669), fontSize: 13),
        ),
      );
    }
  }

  // Chip مستوى الأولوية
  Widget _priorityChip(String priority) {
    Color bg;
    Color textColor;
    switch (priority) {
      case "عاجل جدا":
        bg = Colors.red.shade100;
        textColor = Colors.red.shade800;
        break;
      case "متوسط":
        bg = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        break;
      default:
        bg = Colors.green.shade100;
        textColor = Colors.green.shade800;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        priority,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  // الجدول (Responsive)
  Widget _buildDataTable(List<Product> filtered, BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    if (isMobile) {
      // عرض كروت في الموبايل
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final product = filtered[index];
            final isOut = product.quantity == 0;
            final isLow =
                product.quantity > 0 && product.quantity < product.min;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("الكود: ${product.code}"),
                        _priorityChip(product.priority),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("الكمية: ${product.quantity}"),
                        _statusChip(isOut, isLow),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () => _openRestockDialog(index),
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text("إعادة التخزين"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }

    // جدول الديسكتوب
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.borderColor),
      ),
      color: AppColors.surfaceColor,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: const BoxDecoration(
                color: Color(0xFFF9FAFB),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: const [
                  Expanded(
                    child: Text(
                      "الكود",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "اسم المنتج",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "الكمية الحالية",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "الحد الأدنى",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "الحالة",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "الأولوية",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "آخر تخزين",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "العمليات",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            // Body
            Expanded(
              child: ListView.separated(
                itemCount: filtered.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: Colors.grey.shade200),
                itemBuilder: (context, index) {
                  final product = filtered[index];
                  final isOut = product.quantity == 0;
                  final isLow =
                      product.quantity > 0 && product.quantity < product.min;

                  return Container(
                    color: isOut
                        ? Colors.red.shade50
                        : (isLow ? Colors.yellow.shade50 : Colors.transparent),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Expanded(child: Text(product.code)),
                        Expanded(flex: 2, child: Text(product.name)),
                        Expanded(
                          child: Text(
                            "${product.quantity}",
                            style: TextStyle(
                              color: isOut
                                  ? Colors.red
                                  : (isLow ? Colors.orange : Colors.green),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(child: Text("${product.min}")),
                        Expanded(child: _statusChip(isOut, isLow)),
                        Expanded(child: _priorityChip(product.priority)),
                        Expanded(child: Text(product.lastRestock)),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _openRestockDialog(index),
                            icon: const Icon(Icons.refresh, size: 16),
                            label: const Text("إعادة التخزين"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
