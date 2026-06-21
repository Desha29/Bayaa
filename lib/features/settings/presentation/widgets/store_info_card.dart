// ignore_for_file: deprecated_member_use
// store_info_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:file_picker/file_picker.dart';
import 'package:crazy_phone_pos/core/components/app_logo.dart';

import '../../../../core/functions/messege.dart';
import '../../data/models/store_info_model.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_states.dart';
import 'edit_store_info_dialog.dart';

import 'package:crazy_phone_pos/core/constants/app_colors.dart';

class StoreInfoCard extends StatelessWidget {
  const StoreInfoCard({
    super.key,
    required this.isMobile,
  });

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
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

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.borderColor.withOpacity(0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.015),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Card header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.borderColor.withOpacity(0.4),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        LucideIcons.store,
                        size: 16,
                        color: AppColors.secondaryColor,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'معلومات المتجر',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (cubit.isAdmin() && store != null)
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: isLoading
                              ? null
                              : () => _showEditDialog(context, store!.toMap()),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.primaryColor.withOpacity(0.15),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(LucideIcons.pencil, size: 13, color: AppColors.primaryColor),
                                const SizedBox(width: 4),
                                const Text(
                                  'تعديل',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Card body
              Padding(
                padding: const EdgeInsets.all(16),
                child: isLoading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                      )
                    : store != null
                        ? _buildStoreContent(context, store, cubit)
                        : Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                children: [
                                  Icon(
                                    LucideIcons.store,
                                    size: 36,
                                    color: AppColors.mutedColor.withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'لا توجد معلومات متجر',
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      color: AppColors.mutedColor,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStoreContent(BuildContext context, StoreInfo store, SettingsCubit cubit) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 500;
        return Column(
          children: [
            // Store logo
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.borderColor.withOpacity(0.4),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withOpacity(0.06),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: const AppLogo(
                          width: 100, height: 100, fit: BoxFit.cover),
                    ),
                  ),
                  if (cubit.isAdmin())
                    GestureDetector(
                      onTap: () => _pickImage(context, store),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryColor.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(LucideIcons.camera,
                            size: 14, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Info rows
            if (isWide)
              Wrap(
                spacing: 12,
                runSpacing: 10,
                children: _buildInfoItems(store)
                    .map((item) => SizedBox(
                        width: (constraints.maxWidth - 12) / 2,
                        child: item))
                    .toList(),
              )
            else
              Column(
                children: _buildInfoItems(store)
                    .map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: item))
                    .toList(),
              ),
          ],
        );
      },
    );
  }

  List<Widget> _buildInfoItems(StoreInfo store) {
    return [
      _StoreInfoRow(
        icon: LucideIcons.store,
        label: 'اسم المتجر',
        value: store.name,
      ),
      _StoreInfoRow(
        icon: LucideIcons.mapPin,
        label: 'العنوان',
        value: store.address,
      ),
      _StoreInfoRow(
        icon: LucideIcons.phone,
        label: 'رقم الهاتف',
        value: store.phone,
      ),
      _StoreInfoRow(
        icon: LucideIcons.mail,
        label: 'البريد الإلكتروني',
        value: store.email,
      ),
      _StoreInfoRow(
        icon: LucideIcons.fileText,
        label: 'الرقم الضريبي',
        value: store.vat,
      ),
    ];
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

  void _pickImage(BuildContext context, StoreInfo currentInfo) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (result != null && result.files.single.path != null) {
        final newPath = result.files.single.path!;

        final updatedMap = currentInfo.toMap();
        updatedMap['logoPath'] = newPath;

        if (context.mounted) {
          SettingsCubit.get(context).updateStoreInfo(updatedMap);
        }
      }
    } catch (e) {
      if (context.mounted) {
        MotionSnackBarError(context, "حدث خطأ أثناء اختيار الصورة");
      }
    }
  }
}

class _StoreInfoRow extends StatelessWidget {
  const _StoreInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.borderColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.06),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              size: 14,
              color: AppColors.primaryColor.withOpacity(0.7),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.mutedColor,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
