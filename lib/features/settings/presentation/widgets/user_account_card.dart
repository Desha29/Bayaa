import 'package:flutter/material.dart';
import 'package:bayaa_pos/features/auth/presentation/models/user_view_data.dart';
import 'package:bayaa_pos/features/settings/presentation/models/user_row_view_data.dart';
import 'package:bayaa_pos/l10n/app_localizations.dart';
import 'package:bayaa_pos/shared/theme/app_colors.dart';
import 'package:bayaa_pos/shared/widgets/asset_image_view.dart';

enum _UserAction { edit, delete }

class UserAccountCard extends StatelessWidget {
  const UserAccountCard({
    super.key,
    required this.user,
    required this.details,
    required this.onEdit,
    required this.onDelete,
  });

  final UserRowViewData user;
  final UserViewData details;
  final VoidCallback? onEdit, onDelete;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final ar = l.localeName == 'ar';
    final status = user.active ? l.active : l.disabled;
    final statusColor =
        user.active ? AppColors.successColor : AppColors.errorColor;
    return Material(
      color: AppColors.surfaceColor,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.borderColor)),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        primary: false,
        padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            AssetImageView(
                path: details.imagePath,
                width: 32,
                height: 32,
                borderRadius: 9,
                fallback: ColoredBox(
                    color: AppColors.primaryColor.withValues(alpha: .08),
                    child: Icon(Icons.person_outline,
                        size: 18, color: AppColors.primaryColor))),
            const Spacer(),
            if (onEdit != null || onDelete != null)
              PopupMenuButton<_UserAction>(
                tooltip: ar ? 'خيارات المستخدم' : 'User actions',
                icon: const Icon(Icons.more_horiz, size: 19),
                onSelected: (action) {
                  switch (action) {
                    case _UserAction.edit:
                      onEdit?.call();
                    case _UserAction.delete:
                      onDelete?.call();
                  }
                },
                itemBuilder: (_) => [
                  if (onEdit != null)
                    PopupMenuItem(
                        value: _UserAction.edit,
                        child: Text(l.editPermissions)),
                  if (onDelete != null)
                    PopupMenuItem(
                        value: _UserAction.delete,
                        child: Text(l.deleteAccount,
                            style: TextStyle(color: AppColors.errorColor))),
                ],
              ),
          ]),
          const SizedBox(height: 2),
          Text(user.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                  fontSize: 13,
                  color: AppColors.textPrimary)),
          Text('@${details.username}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, color: AppColors.mutedColor)),
          const SizedBox(height: 7),
          Wrap(spacing: 4, runSpacing: 4, children: [
            _badge(user.roleLabel, user.roleColor),
            _badge(status, statusColor),
          ]),
          const SizedBox(height: 7),
          Tooltip(
              message: '${l.lastLoginColumn}: ${user.lastLogin}',
              child: Row(children: [
                Icon(Icons.schedule, size: 13, color: AppColors.mutedColor),
                const SizedBox(width: 5),
                Expanded(
                    child: Text(user.lastLogin.isEmpty ? '—' : user.lastLogin,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 11, color: AppColors.mutedColor))),
              ])),
        ]),
      ),
    );
  }

  Widget _badge(String label, Color color) => DecoratedBox(
        decoration: BoxDecoration(
            color: color.withValues(alpha: .09),
            borderRadius: BorderRadius.circular(6)),
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            child: Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.bold, color: color))),
      );
}
