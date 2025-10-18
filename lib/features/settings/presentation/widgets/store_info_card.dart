// store_info_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/components/section_card.dart';

import '../../../../core/functions/messege.dart';
import '../../data/models/store_info_model.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_states.dart';
import 'edit_store_info_dialog.dart';

class StoreInfoCard extends StatelessWidget {
  const StoreInfoCard({
    super.key,
    required this.isMobile,
  });

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<SettingsCubit, SettingsStates>(
      listener: (context, state) {
        if (state is StoreInfoUpdateSuccess) {
          MotionSnackBarSuccess(context, state.message);
        } else if (state is StoreInfoUpdateFailure) {
          MotionSnackBarError(context, state.message);
        }
      },
      builder: (context, state) {
        final cubit = SettingsCubit.get(context);
        final isLoading = state is SettingsLoading;

        StoreInfo? store;
        if (state is StoreInfoLoaded) {
          store = state.storeInfo;
        } else if (!isLoading) {
          try {
            store = cubit.currentStoreInfo;
          } catch (e) {
            store = null;
          }
        }

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
                  if (cubit.isAdmin() && store != null)
                    IconButton(
                      onPressed: isLoading
                          ? null
                          : () => _showEditDialog(context, store!.toMap()),
                      icon: const Icon(LucideIcons.edit2, size: 16),
                      tooltip: 'تعديل معلومات المتجر',
                    ),
                ],
              ),
              SizedBox(height: isMobile ? 12 : 16),
              if (isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (store != null)
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 700;
                    final infoList = [
                      _StoreInfoRow(
                        icon: LucideIcons.store,
                        label: 'اسم المتجر',
                        value: store!.name,
                        theme: theme,
                      ),
                      _StoreInfoRow(
                        icon: LucideIcons.mapPin,
                        label: 'العنوان',
                        value: store.address,
                        theme: theme,
                      ),
                      _StoreInfoRow(
                        icon: LucideIcons.phone,
                        label: 'رقم الهاتف',
                        value: store.phone,
                        theme: theme,
                      ),
                      _StoreInfoRow(
                        icon: LucideIcons.mail,
                        label: 'البريد الإلكتروني',
                        value: store.email,
                        theme: theme,
                      ),
                      _StoreInfoRow(
                        icon: LucideIcons.fileText,
                        label: 'الرقم الضريبي',
                        value: store.vat,
                        theme: theme,
                      ),
                    ];

                    if (isWide) {
                      return Wrap(
                        spacing: 16,
                        runSpacing: 12,
                        children: infoList.map((row) {
                          return SizedBox(
                            width: (constraints.maxWidth - 16) / 2,
                            child: row,
                          );
                        }).toList(),
                      );
                    } else {
                      return Column(
                        children: infoList
                            .map((row) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: row,
                                ))
                            .toList(),
                      );
                    }
                  },
                )
              else
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text('لا توجد معلومات متجر'),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, Map<String, String> store) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) => EditStoreInfoDialog(storeInfo: store),
    );

    if (result != null && context.mounted) {
      SettingsCubit.get(context).updateStoreInfo(result);
    }
  }
}

class _StoreInfoRow extends StatelessWidget {
  const _StoreInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.theme,
  });

  final IconData icon;
  final String label;
  final String value;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
