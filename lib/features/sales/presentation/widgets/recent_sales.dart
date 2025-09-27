import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class RecentSalesWidget extends StatelessWidget {
  final List<Map<String, dynamic>> sales;

  const RecentSalesWidget({super.key, required this.sales});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "المبيعات الأخيرة",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sales.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final s = sales[index];
                final date = s['date'] as DateTime;
                final formatted =
                    "${date.year}/${date.month}/${date.day} - ${date.hour}:${date.minute}";

                return Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${s['total']} ج.م",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            formatted,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
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
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
