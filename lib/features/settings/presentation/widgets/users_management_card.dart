import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/components/section_card.dart';

import '../../data/models/user_row.dart';
import 'mobile_user_list.dart';
import 'desktop_user_table.dart';

class UsersManagementCard extends StatelessWidget {
  const UsersManagementCard({
    super.key,
    required this.users,
    required this.isMobile,
  });

  final List<UserRow> users;
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
                LucideIcons.users,
                size: 18,
                color: Colors.grey[700],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'إدارة المستخدمين',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(LucideIcons.plus, size: 18),
                label: Text(isMobile ? 'إضافة' : 'إضافة مستخدم جديد'),
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 12 : 16,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 12 : 16),
          if (isMobile)
            MobileUserList(users: users)
          else
            DesktopUserTable(users: users),
        ],
      ),
    );
  }
}
