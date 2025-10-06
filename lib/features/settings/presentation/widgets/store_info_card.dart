import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/components/section_card.dart';

class StoreInfoCard extends StatelessWidget {
  const StoreInfoCard({
    super.key,
    required this.store,
    required this.isMobile,
  });

  final Map<String, String> store;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.store,
                size: 18,
                color: Colors.grey[700],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'معلومات المتجر',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                LucideIcons.shield,
                size: 16,
                color: Colors.grey[600],
              ),
            ],
          ),
          SizedBox(height: isMobile ? 12 : 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 700;
              final children = [
                _LabeledStaticField(
                  label: 'اسم المتجر',
                  value: store['name']!,
                ),
                _LabeledStaticField(
                  label: 'رقم الهاتف',
                  value: store['phone']!,
                ),
                _LabeledStaticField(
                  label: 'البريد الإلكتروني',
                  value: store['email']!,
                ),
                _LabeledStaticField(
                  label: 'العنوان',
                  value: store['address']!,
                  maxLines: 2,
                ),
                _LabeledStaticField(
                  label: 'الرقم الضريبي',
                  value: store['vat']!,
                ),
              ];

              if (!isWide) {
                return Column(
                  children: [
                    for (var i = 0; i < children.length; i++) ...[
                      children[i],
                      if (i < children.length - 1) const Divider(height: 24),
                    ],
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        children[0],
                        const Divider(height: 24),
                        children[2],
                        const Divider(height: 24),
                        children[4],
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      children: [
                        children[1],
                        const Divider(height: 24),
                        children[3],
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              icon: const Icon(LucideIcons.lock, size: 18),
              label: Text(isMobile ? 'حفظ' : 'حفظ معلومات المتجر'),
              style: FilledButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12 : 16,
                  vertical: 12,
                ),
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}

class _LabeledStaticField extends StatelessWidget {
  const _LabeledStaticField({
    required this.label,
    required this.value,
    this.maxLines = 1,
  });

  final String label;
  final String value;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment:
          maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: theme.bodyMedium?.copyWith(color: Colors.grey[700]),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 5,
          child: Text(
            value,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.left,
            style: theme.bodyMedium?.copyWith(color: Colors.grey[900]),
          ),
        ),
      ],
    );
  }
}
