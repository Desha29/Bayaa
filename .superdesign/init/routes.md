# ERP destinations
### lib/app/navigation/erp_destinations.dart

```dart
import 'package:bayaa_pos/app/shell/widgets/erp_header.dart';
import 'package:bayaa_pos/features/auth/presentation/models/user_view_data.dart';
import 'package:bayaa_pos/features/notifications/presentation/controllers/notifications_cubit.dart';
import 'package:bayaa_pos/features/notifications/presentation/controllers/notifications_state.dart';
import 'package:bayaa_pos/features/inventory/presentation/controllers/stock_cubit.dart';
import 'package:bayaa_pos/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bayaa_pos/shared/theme/app_colors.dart';
import 'package:bayaa_pos/shared/widgets/screen_header.dart';
import 'package:bayaa_pos/app/bootstrap/service_locator.dart';
import 'package:bayaa_pos/shared/feedback/app_messages.dart';
import 'package:bayaa_pos/features/auth/presentation/controllers/user_cubit.dart';
import 'package:bayaa_pos/features/auth/presentation/controllers/user_state.dart';
import 'package:bayaa_pos/features/invoices/presentation/controllers/invoice_cubit.dart';
import 'package:bayaa_pos/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:bayaa_pos/features/products/presentation/controllers/product_cubit.dart';
import 'package:bayaa_pos/features/products/presentation/screens/products_screen.dart';
import 'package:bayaa_pos/preview/sources/sample_invoice_source.dart';

import 'package:bayaa_pos/features/pos/presentation/screens/pos_screen.dart';
import 'package:bayaa_pos/features/settings/presentation/screens/settings_screen.dart';
import 'package:bayaa_pos/features/inventory/presentation/controllers/stock_state.dart';
import 'package:bayaa_pos/features/inventory/presentation/screens/stock_screen.dart';
import 'package:bayaa_pos/features/invoices/presentation/screens/invoices_screen.dart';

import 'package:bayaa_pos/features/sessions/presentation/screens/sessions_dashboard_screen.dart';
import 'package:bayaa_pos/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:bayaa_pos/features/analytics/presentation/controllers/analytics_cubit.dart';
import 'package:bayaa_pos/preview/sources/sample_analytics_source.dart';

import 'package:bayaa_pos/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:bayaa_pos/app/shell/widgets/erp_sidebar.dart';
import 'package:bayaa_pos/features/stock_summary/presentation/screens/stock_summary_screen.dart';
import 'package:bayaa_pos/features/stock_summary/presentation/controllers/stock_summary_cubit.dart';
import 'package:bayaa_pos/features/expenses/presentation/screens/expenses_screen.dart';

import 'package:bayaa_pos/app/navigation/erp_destination.dart';
import 'package:bayaa_pos/features/customers/presentation/screens/customers_screen.dart';
import 'package:bayaa_pos/features/suppliers/presentation/screens/suppliers_screen.dart';
import 'package:bayaa_pos/features/purchases/presentation/screens/purchases_screen.dart';
import 'package:bayaa_pos/features/purchase_returns/presentation/screens/purchase_returns_screen.dart';
import 'package:bayaa_pos/features/finance/presentation/screens/finance_screen.dart';
import 'package:bayaa_pos/features/warehouses/presentation/screens/warehouses_screen.dart';

List<ErpDestination> buildErpDestinations(BuildContext context, {required ValueChanged<String> onCardTap}) {
  final salesSource = getIt<SampleInvoiceSource>();
  final analyticsSource = getIt<SampleAnalyticsSource>();
  final currentUser = getIt<UserCubit>().currentUser;

    final l10n = AppLocalizations.of(context);
    return [
      ErpDestination(
        id: 'dashboard',
        icon: LucideIcons.layoutDashboard,
        title: l10n.dashboard,
        screen: DashboardScreen(
          onCardTap: (id) => onCardTap(id),
          isManager: currentUser.userType == PreviewRole.manager,
        ),
      ),
      ErpDestination(
        id: 'sales',
        icon: LucideIcons.shoppingCart,
        title: l10n.sales,
        screen: PosScreen(repository: salesSource),
      ),
      ErpDestination(
        id: 'invoices',
        icon: LucideIcons.fileText,
        title: l10n.invoices,
        screen: BlocProvider<InvoiceCubit>(
          create: (_) => InvoiceCubit(salesSource),
          child:
              InvoiceScreen(repository: salesSource, currentUser: currentUser),
        ),
      ),
      ErpDestination(
        id: 'products',
        icon: LucideIcons.box,
        title: l10n.products,
        screen: const ProductsScreen(),
      ),
      ErpDestination(
        id: 'stock_alerts',
        icon: LucideIcons.triangleAlert,
        title: l10n.stockAlerts,
        screen: const StockScreen(),
      ),
      if (currentUser.userType != PreviewRole.cashier)
        ErpDestination(
          id: 'stock_summary',
          icon: LucideIcons.clipboardList,
          title: l10n.stockSummary,
          screen: BlocProvider(
            create: (_) => getIt<StockSummaryCubit>()..init(),
            child: const StockSummaryScreen(),
          ),
        ),
      if (currentUser.userType == PreviewRole.manager)
        ErpDestination(
          id: 'reports',
          icon: LucideIcons.chartPie,
          title: l10n.reports,
          screen: BlocProvider(
            create: (context) => AnalyticsCubit(analyticsSource),
            child: const AnalyticsScreen(),
          ),
        ),
      if (currentUser.userType == PreviewRole.manager)
        ErpDestination(
          id: 'sessions',
          icon: LucideIcons.history,
          title: l10n.sessions,
          screen: BlocProvider(
            create: (context) => AnalyticsCubit(analyticsSource),
            child: const SessionsDashboardScreen(),
          ),
        ),
      ErpDestination(
        id: 'notifications',
        icon: LucideIcons.bell,
        title: l10n.notifications,
        screen: const NotificationsScreen(),
      ),
      ErpDestination(
        id: 'expenses',
        icon: LucideIcons.walletCards,
        title: l10n.localeName == 'ar' ? 'المصروفات' : 'Expenses',
        screen: const ExpensesScreen(),
      ),
      ErpDestination(id: 'customers', icon: Icons.people_outline,
        title: l10n.localeName == 'ar' ? 'العملاء' : 'Customers', screen: const CustomersScreen()),
      ErpDestination(id: 'suppliers', icon: Icons.local_shipping_outlined,
        title: l10n.localeName == 'ar' ? 'الموردون' : 'Suppliers', screen: const SuppliersScreen()),
      ErpDestination(id: 'purchases', icon: Icons.shopping_bag_outlined,
        title: l10n.localeName == 'ar' ? 'المشتريات' : 'Purchases', screen: const PurchasesScreen()),
      ErpDestination(id: 'purchase_returns', icon: Icons.assignment_return_outlined,
        title: l10n.localeName == 'ar' ? 'مرتجعات المشتريات' : 'Purchase returns', screen: const PurchaseReturnsScreen()),
      ErpDestination(id: 'finance', icon: Icons.account_balance_outlined,
        title: l10n.localeName == 'ar' ? 'المالية' : 'Finance', screen: const FinanceScreen()),
      ErpDestination(id: 'warehouses', icon: Icons.warehouse_outlined,
        title: l10n.localeName == 'ar' ? 'الفروع والمخازن' : 'Stores & warehouses', screen: const WarehousesScreen()),
      ErpDestination(
        id: 'settings',
        icon: LucideIcons.settings,
        title: l10n.settings,
        screen: const SettingsScreen(),
      ),
    ];
  
}

```
