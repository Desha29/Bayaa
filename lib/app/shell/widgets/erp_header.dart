import 'package:bayaa_pos/preview/branch_preview_controller.dart';
import 'dart:async';
import 'package:bayaa_pos/features/auth/presentation/models/user_view_data.dart';
import 'package:bayaa_pos/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bayaa_pos/shared/theme/app_colors.dart';
import 'package:bayaa_pos/shared/widgets/asset_image_view.dart';
import 'package:bayaa_pos/app/bootstrap/service_locator.dart';
import 'package:bayaa_pos/shared/localization/translation_helper.dart';
import 'package:bayaa_pos/shared/localization/locale_provider.dart';
import 'package:bayaa_pos/features/settings/presentation/widgets/add_edit_user_dialog.dart';

class DateTimeBadge extends StatefulWidget {
  const DateTimeBadge({super.key});

  @override
  State<DateTimeBadge> createState() => DashboardDateTimeBadgeState();
}

class DashboardDateTimeBadgeState extends State<DateTimeBadge> {
  late DateTime _now;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _now = DateTime.now());
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final formatted =
        DateFormat('EEE d MMM, HH:mm:ss', l10n.localeName).format(_now);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.clock, size: 14, color: AppColors.mutedColor),
          const SizedBox(width: 6),
          Text(
            formatted,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class LanguageToggle extends StatelessWidget {
  final bool compact;
  const LanguageToggle({super.key, required this.compact});

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    final isArabic = AppLocalizations.of(context).localeName == 'ar';
    final foreground =
        compact ? AppColors.sidebarForeground : AppColors.textSecondary;

    return Tooltip(
      message: isArabic ? 'English' : 'العربية',
      child: InkWell(
        onTap: () => getIt<LocaleProvider>().toggleLocale(),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 38,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: EdgeInsets.symmetric(horizontal: compact ? 9 : 12),
          decoration: BoxDecoration(
            color: compact
                ? Colors.white.withOpacity(.12)
                : AppColors.backgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: compact ? null : Border.all(color: AppColors.borderColor),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.language, size: 18, color: foreground),
            if (!compact) ...[
              const SizedBox(width: 6),
              Text(
                isArabic ? 'EN' : 'ع',
                style: TextStyle(
                    color: foreground,
                    fontSize: 12,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ]),
        ),
      ),
    );
  }
}

class ErpDesktopHeader extends StatelessWidget {
  final String pageTitle;
  final IconData pageIcon;
  final List<Widget> actions;
  final VoidCallback? onSearch;
  const ErpDesktopHeader({
    super.key,
    required this.pageTitle,
    required this.pageIcon,
    required this.actions,
    this.onSearch,
  });

  @override
  Widget build(BuildContext context) => Builder(builder: (context) {
        Theme.of(context);
        return Container(
          height: 74,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          decoration: BoxDecoration(
            color: AppColors.surfaceColor,
            border: Border(bottom: BorderSide(color: AppColors.borderColor)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withOpacity(.03),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.secondaryColor.withOpacity(.09),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(pageIcon, size: 18, color: AppColors.secondaryColor),
            ),
            const SizedBox(width: 10),
            ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 160),
                child: Text(
                  pageTitle,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                )),
            const SizedBox(width: 18),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: onSearch,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        height: 40,
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.borderColor),
                        ),
                        child: Row(
                          children: [
                            Icon(LucideIcons.search,
                                size: 16, color: AppColors.mutedColor),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context).localeName == 'ar'
                                    ? 'ابحث برقم الفاتورة، المنتج، أو الباركود...'
                                    : 'Search by invoice #, product, or barcode...',
                                style: TextStyle(
                                  color: AppColors.mutedColor,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const HeaderBranchSelector(),
                ],
              ),
            ),
            ...actions,
          ]),
        );
      });
}

class ProfileMenu extends StatelessWidget {
  final UserViewData user;
  final bool compact;
  const ProfileMenu({super.key, required this.user, required this.compact});

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    final name = TranslationHelper.translateUserName(context, user.name,
        username: user.username);
    final initial = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?';
    return PopupMenuButton<String>(
      tooltip: name,
      offset: const Offset(0, 48),
      onSelected: (value) {
        if (value == 'edit-profile') {
          showDialog<UserViewData>(
            context: context,
            builder: (_) => AddEditUserDialog(
              userToEdit: user,
              profileOnly: true,
            ),
          );
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem<String>(
          enabled: false,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(name,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                Text(user.username,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: AppColors.mutedColor)),
              ]),
        ),
        PopupMenuItem<String>(
          value: 'edit-profile',
          child: Row(
            children: [
              Icon(LucideIcons.pencil,
                  size: 18, color: AppColors.secondaryColor),
              const SizedBox(width: 10),
              Text(
                AppLocalizations.of(context).localeName == 'ar'
                    ? 'تعديل الملف الشخصي'
                    : 'Edit profile',
              ),
            ],
          ),
        ),
      ],
      child: Container(
        padding:
            EdgeInsets.symmetric(horizontal: compact ? 4 : 10, vertical: 6),
        decoration: BoxDecoration(
          color: compact
              ? Colors.white.withOpacity(.12)
              : AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          AssetImageView(
            path: user.imagePath,
            width: 32,
            height: 32,
            borderRadius: 16,
            fallback: Container(
              color: AppColors.secondaryColor,
              alignment: Alignment.center,
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          if (!compact) ...[
            const SizedBox(width: 8),
            ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 130),
                child: Text(name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary))),
            const SizedBox(width: 4),
            Icon(LucideIcons.chevronDown,
                size: 16, color: AppColors.mutedColor),
          ],
        ]),
      ),
    );
  }
}

class HeaderBranchSelector extends StatelessWidget {
  const HeaderBranchSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = BranchPreviewController.instance;
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    return ListenableBuilder(
      listenable: scope,
      builder: (context, _) => PopupMenuButton<String>(
        tooltip: ar ? 'اختيار الفرع' : 'Select branch',
        initialValue: scope.activeId,
        onSelected: scope.select,
        itemBuilder: (_) => [
          for (var i = 0; i < BranchPreviewController.branchIds.length; i++)
            CheckedPopupMenuItem(
              value: BranchPreviewController.branchIds[i],
              checked: scope.activeId == BranchPreviewController.branchIds[i],
              child: Text(
                (ar
                    ? BranchPreviewController.labelsAr
                    : BranchPreviewController.labelsEn)[i],
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
        ],
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.backgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.storefront_outlined,
                  size: 17, color: AppColors.primaryColor),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 130),
                child: Text(
                  scope.label(ar),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.keyboard_arrow_down_rounded,
                  size: 18, color: AppColors.mutedColor),
            ],
          ),
        ),
      ),
    );
  }
}
