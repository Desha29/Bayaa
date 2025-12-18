import 'package:crazy_phone_pos/core/constants/app_colors.dart';
import 'package:crazy_phone_pos/features/auth/presentation/cubit/user_cubit.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CloseDayCard extends StatelessWidget {
  final bool isMobile;

  const CloseDayCard({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showConfirmationDialog(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  LucideIcons.doorClosed,
                  color: Colors.red,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'إغلاق اليومية',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 16 : 18,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'إنهاء الوردية الحالية وإصدار تقرير الإغلاق',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.mutedColor,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد إغلاق اليومية'),
        content: const Text(
            'هل أنت متأكد من رغبتك في إغلاق اليومية؟ سيتم إنشاء تقرير الإغلاق ولا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              UserCubit.get(context).closeSession();
            },
            child: const Text('إغلاق اليومية'),
          ),
        ],
      ),
    );
  }
}
