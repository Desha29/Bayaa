
import 'package:flutter/material.dart';
import 'package:crazy_phone_pos/core/components/screen_header.dart';
import 'package:crazy_phone_pos/core/constants/app_colors.dart';

import '../data/models/user_row.dart';
import 'widgets/logout_warning_banner.dart';
import 'widgets/store_info_card.dart';
import 'widgets/users_management_card.dart';


class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock store data
    final store = {
      'name': 'Crazy Phone',
      'phone': '966+ 11 123 4567',
      'email': 'info@crazyphone.sa',
      'address': 'شارع الملك فهد، الرياض، المملكة العربية السعودية',
      'vat': '123456789012345',
    };

    // Mock users data
    final users = <UserRow>[
      UserRow(
        name: 'أحمد محمد',
        email: 'ahmed@crazyphone.sa',
        roleLabel: 'مدير النظام',
        roleTint: const Color(0xFFFEE2E2),
        roleColor: const Color(0xFFDC2626),
        active: true,
        lastLogin: '١٤٥٣/٢/٣',
      ),
      UserRow(
        name: 'فاطمة علي',
        email: 'fatima@crazyphone.sa',
        roleLabel: 'كاشير',
        roleTint: const Color(0xFFE0F2FE),
        roleColor: const Color(0xFF0369A1),
        active: true,
        lastLogin: '١٤٥٣/٢/٣',
      ),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;
              final padding = isMobile ? 16.0 : 24.0;

              return Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ScreenHeader(
                      title: 'الإعدادات',
                      subtitle: 'إعدادات النظام وإدارة المستخدمين',
                    ),
                    SizedBox(height: isMobile ? 12 : 16),
                    LogoutWarningBanner(isMobile: isMobile),
                    SizedBox(height: isMobile ? 12 : 16),
                    Expanded(
                      child: ListView(
                        children: [
                          StoreInfoCard(
                            store: store,
                            isMobile: isMobile,
                          ),
                          SizedBox(height: isMobile ? 12 : 16),
                          UsersManagementCard(
                            users: users,
                            isMobile: isMobile,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
