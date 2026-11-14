import 'package:flutter/material.dart';
import 'package:bayaa_pos/shared/widgets/erp/erp_view_spec.dart';

// Display examples only; this feature has no business model or persistence.
final financeView = ErpViewSpec(
  id: 'finance',
  title: UiLabel('Finance', 'المالية'),
  subtitle: UiLabel('Cash accounts, payment overview, and balances',
      'حسابات النقدية وملخص المدفوعات والأرصدة'),
  icon: Icons.account_balance_outlined,
  action: UiLabel('Add account', 'إضافة حساب'),
  columns: [
    UiLabel('Account', 'الحساب'),
    UiLabel('Type', 'النوع'),
    UiLabel('Branch', 'الفرع'),
    UiLabel('Currency', 'العملة'),
    UiLabel('Balance', 'الرصيد')
  ],
  metrics: [
    ErpMetricSpec(UiLabel('Cash & bank', 'النقدية والبنوك'), '124,650 EGP',
        Icons.account_balance_outlined),
    ErpMetricSpec(UiLabel('Receivables', 'مستحقات العملاء'), '48,250 EGP',
        Icons.south_west),
    ErpMetricSpec(UiLabel('Payables', 'مستحقات الموردين'), '92,600 EGP',
        Icons.north_east),
    ErpMetricSpec(UiLabel('Net position', 'صافي الرصيد'), '80,300 EGP',
        Icons.account_balance_wallet_outlined)
  ],
  records: [
    ErpRecordView(
        id: 'ACC-001',
        title: 'Main cash account',
        subtitle: 'Cash drawer · Main branch',
        cells: ['Main cash account', 'Cash', 'Cairo', 'EGP', '28,450 EGP'],
        status: UiLabel('Active', 'نشط'),
        tone: ErpStatusTone.success),
    ErpRecordView(
        id: 'ACC-002',
        title: 'Bank current account',
        subtitle: 'Operating bank account',
        cells: [
          'Bank current account',
          'Bank',
          'All branches',
          'EGP',
          '85,000 EGP'
        ],
        status: UiLabel('Active', 'نشط'),
        tone: ErpStatusTone.success),
    ErpRecordView(
        id: 'ACC-003',
        title: 'Mobile wallet',
        subtitle: 'Digital collections · Sample account',
        cells: ['Mobile wallet', 'Wallet', 'Cairo', 'EGP', '7,200 EGP'],
        status: UiLabel('Review', 'للمراجعة'),
        tone: ErpStatusTone.warning),
    ErpRecordView(
        id: 'ACC-004',
        title: 'Giza cash account',
        subtitle: 'Cash drawer · Giza branch',
        cells: ['Giza cash account', 'Cash', 'Giza', 'EGP', '4,000 EGP'],
        status: UiLabel('Active', 'نشط'),
        tone: ErpStatusTone.success)
  ],
  fields: [
    ErpFieldSpec(UiLabel('Account name', 'اسم الحساب'), wide: false),
    ErpFieldSpec(UiLabel('Account type', 'نوع الحساب'), wide: false),
    ErpFieldSpec(UiLabel('Branch', 'الفرع'), wide: false),
    ErpFieldSpec(UiLabel('Currency', 'العملة'), wide: false),
    ErpFieldSpec(UiLabel('Opening balance', 'الرصيد الافتتاحي'), wide: false),
    ErpFieldSpec(UiLabel('Reference', 'المرجع'), wide: false),
    ErpFieldSpec(UiLabel('Notes', 'ملاحظات'), wide: true)
  ],
  filters: [
    UiLabel('All', 'الكل'),
    UiLabel('Active', 'نشط'),
    UiLabel('Review', 'للمراجعة')
  ],
);
