import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final _barcodeController = TextEditingController();

  List<Map<String, dynamic>> cartItems = [
    {
      "id": "P001",
      "name": "آيفون 14 برو",
      "price": 4500.0,
      "qty": 1,
      "date": DateTime(2025, 9, 1),
    },
    {
      "id": "P002",
      "name": "سامسونج جالاكسي S23",
      "price": 3200.0,
      "qty": 2,
      "date": DateTime(2025, 9, 10),
    },
  ];

  List<Map<String, dynamic>> recentSales = [
    {"total": 2800.0, "items": 3, "date": DateTime(2025, 9, 23, 14, 30)},
    {"total": 4500.0, "items": 1, "date": DateTime(2025, 9, 23, 14, 15)},
  ];

  @override
  void dispose() {
    _barcodeController.dispose();
    super.dispose();
  }

  void _updateQuantity(int index, int change) {
    setState(() {
      if (cartItems[index]['qty'] + change > 0) {
        cartItems[index]['qty'] += change;
      }
    });
  }

  void _removeItem(int index) {
    setState(() {
      cartItems.removeAt(index);
    });
  }

  void _clearCart() {
    setState(() {
      cartItems.clear();
    });
  }

  void _addProduct() {
    final text = _barcodeController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      cartItems.add({
        "id": "P${cartItems.length + 1}".padLeft(4, "0"),
        "name": text,
        "price": 1000.0 + cartItems.length * 500,
        "qty": 1,
        "date": DateTime.now(),
      });
    });
    _barcodeController.clear();
  }

  void _checkout() {
    if (cartItems.isEmpty) return;

    final total = cartItems.fold<double>(
      0,
      (sum, item) => sum + (item['qty'] * item['price']),
    );

    setState(() {
      recentSales.insert(0, {
        "total": total,
        "items": cartItems.length,
        "date": DateTime.now(),
      });
      cartItems.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 1000;

    final totalAmount = cartItems.fold<double>(
      0,
      (sum, item) => sum + (item['qty'] * item['price']),
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // قسم المبيعات الرئيسي
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'المبيعات',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'شاشة الكاشير لإدارة عمليات البيع',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Column(
                      children: [
                        _BarcodeScanCard(
                          barcodeController: _barcodeController,
                          onAddProduct: _addProduct,
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: Card(
                            color: AppColors.kCardBackground,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    20,
                                    20,
                                    20,
                                    10,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        "قائمة المنتجات",
                                        style: theme.textTheme.titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(height: 1),
                                Expanded(
                                  child: cartItems.isEmpty
                                      ? const Center(
                                          child: Text(
                                            "لا توجد منتجات في السلة",
                                          ),
                                        )
                                      : ListView.separated(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                          itemCount: cartItems.length,
                                          separatorBuilder: (_, __) =>
                                              const Divider(
                                                indent: 20,
                                                endIndent: 20,
                                              ),
                                          itemBuilder: (context, index) {
                                            final item = cartItems[index];
                                            return _CartItemRow(
                                              id: item['id'],
                                              name: item['name'],
                                              price: item['price'],
                                              quantity: item['qty'],
                                              date: item['date'],
                                              onRemove: () =>
                                                  _removeItem(index),
                                              onQtyIncrease: () =>
                                                  _updateQuantity(index, 1),
                                              onQtyDecrease: () =>
                                                  _updateQuantity(index, -1),
                                            );
                                          },
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _TotalSectionCard(
                          totalAmount: totalAmount,
                          onClearCart: cartItems.isNotEmpty ? _clearCart : null,
                          onCheckout: _checkout,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (isDesktop) ...[
              const SizedBox(width: 24),
              Expanded(flex: 1, child: _RecentSalesWidget(sales: recentSales)),
            ],
          ],
        ),
      ),
    );
  }
}

class _BarcodeScanCard extends StatelessWidget {
  const _BarcodeScanCard({
    required this.barcodeController,
    required this.onAddProduct,
  });

  final TextEditingController barcodeController;
  final VoidCallback onAddProduct;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.kCardBackground,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(LucideIcons.qrCode, color: Colors.grey[600]),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: barcodeController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'امسح الباركود أو أدخل رقم المنتج...',
                ),
                onSubmitted: (_) => onAddProduct(),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              icon: const Icon(LucideIcons.plus, size: 18),
              label: const Text("إضافة منتج"),
              onPressed: onAddProduct,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.kPrimaryBlue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartItemRow extends StatelessWidget {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final DateTime date;
  final VoidCallback onRemove;
  final VoidCallback onQtyIncrease;
  final VoidCallback onQtyDecrease;

  const _CartItemRow({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.date,
    required this.onRemove,
    required this.onQtyIncrease,
    required this.onQtyDecrease,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = price * quantity;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // معلومات المنتج
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$name (كود: $id)",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "تاريخ الإضافة: ${date.year}/${date.month}/${date.day}",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${price.toStringAsFixed(0)} ر.س',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildQtyButton(context, LucideIcons.minus, onQtyDecrease),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '$quantity',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildQtyButton(context, LucideIcons.plus, onQtyIncrease),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${total.toStringAsFixed(0)} ر.س',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            width: 40,
            height: 40,
            child: IconButton(
              icon: const Icon(LucideIcons.trash2, size: 20),
              onPressed: onRemove,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.kDangerRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyButton(
    BuildContext context,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: 35,
      height: 35,
      child: IconButton(
        icon: Icon(icon, size: 16),
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: Colors.grey[200],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}

class _TotalSectionCard extends StatelessWidget {
  final double totalAmount;
  final VoidCallback? onClearCart;
  final VoidCallback onCheckout;

  const _TotalSectionCard({
    required this.totalAmount,
    required this.onClearCart,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(LucideIcons.shoppingCart, size: 18),
                  label: const Text("إنهاء البيع"),
                  onPressed: totalAmount > 0 ? onCheckout : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.kSuccessGreen,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.withOpacity(0.5),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  icon: const Icon(LucideIcons.trash2, size: 18),
                  label: const Text("حذف الكل"),
                  onPressed: onClearCart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.kDangerRed,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.withOpacity(0.5),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "الإجمالي النهائي",
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${totalAmount.toStringAsFixed(0)} ر.س",
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.kPrimaryBlue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentSalesWidget extends StatelessWidget {
  final List<Map<String, dynamic>> sales;

  const _RecentSalesWidget({required this.sales});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 70),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "المبيعات الأخيرة",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.separated(
                      itemCount: sales.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 32, thickness: 0.5),
                      itemBuilder: (context, index) {
                        final s = sales[index];
                        final date = s['date'] as DateTime;
                        final formatted =
                            "${date.year}/${date.month}/${date.day} - ${date.hour}:${date.minute.toString().padLeft(2, "0")}";

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${s['total']} ر.س",
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  formatted,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.kDarkChip,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                "${s['items']} منتج",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
