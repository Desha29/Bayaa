import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../products/data/models/product_model.dart';
import 'product_card.dart';

class RestockDialog extends StatefulWidget {
  final Product product;

  const RestockDialog({super.key, required this.product});

  @override
  State<RestockDialog> createState() => _RestockDialogState();
}

class _RestockDialogState extends State<RestockDialog> {
  final controller = TextEditingController();
  int after = 0;
  String? error;

  @override
  void initState() {
    super.initState();
    after = widget.product.quantity;
  }

  void computeAfter() {
    final v = int.tryParse(controller.text);
    if (v == null) {
      setState(() {
        after = widget.product.quantity;
        error = null;
      });
      return;
    }
    setState(() {
      after = widget.product.quantity + v;
      error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'إعادة تخزين المنتج',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
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
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        widget.product.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'الكمية الحالية: ${widget.product.quantity}',
                          ),
                        ),
                        Expanded(
                          child: Text('الحد الأدنى: ${widget.product.minQuantity}'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'الكمية المطلوبة: ${(widget.product.minQuantity - widget.product.quantity) > 0 ? (widget.product.minQuantity - widget.product.quantity).toString() : '0'}',
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
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                        final v = int.tryParse(controller.text);
                        if (v == null || v <= 0) {
                          setState(() {
                            error = 'الرجاء إدخال كمية صحيحة أكبر من صفر';
                          });
                          return;
                        }
                        Navigator.of(context).pop(v);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('تأكيد إعادة التخزين'),
                        ),
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
  }
}
