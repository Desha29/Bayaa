import 'package:flutter/material.dart';
import 'package:bayaa_pos/shared/widgets/erp/erp_view_spec.dart';

// Display examples only; this feature has no business model or persistence.
final customersView = ErpViewSpec(
  id: 'customers',
  title: UiLabel('Customers', 'العملاء'),
  subtitle: UiLabel('Customer profiles, balances, and sales relationships',
      'ملفات العملاء والأرصدة وعلاقات المبيعات'),
  icon: Icons.people_outline,
  action: UiLabel('Add customer', 'إضافة عميل'),
  columns: [
    UiLabel('Customer', 'العميل'),
    UiLabel('Phone', 'الهاتف'),
    UiLabel('City', 'المدينة'),
    UiLabel('Invoices', 'الفواتير'),
    UiLabel('Balance', 'الرصيد')
  ],
  metrics: [
    ErpMetricSpec(UiLabel('Customers', 'العملاء'), '248', Icons.people_outline),
    ErpMetricSpec(UiLabel('Active accounts', 'حسابات نشطة'), '231',
        Icons.verified_user_outlined),
    ErpMetricSpec(UiLabel('Receivables', 'مستحقات العملاء'), '48,250 EGP',
        Icons.account_balance_wallet_outlined),
    ErpMetricSpec(UiLabel('New this month', 'جدد هذا الشهر'), '18',
        Icons.person_add_alt_1_outlined)
  ],
  records: [
    ErpRecordView(
        id: 'CUS-001',
        title: 'Nile Market',
        subtitle: 'Retail customer · Cairo',
        cells: ['Nile Market', '01000000101', 'Cairo', '24', '12,450 EGP'],
        status: UiLabel('Active', 'نشط'),
        tone: ErpStatusTone.success),
    ErpRecordView(
        id: 'CUS-002',
        title: 'سارة إبراهيم',
        subtitle: 'عميل تجزئة · الجيزة',
        cells: ['سارة إبراهيم', '01000000102', 'Giza', '16', '0.00 EGP'],
        status: UiLabel('Active', 'نشط'),
        tone: ErpStatusTone.success),
    ErpRecordView(
        id: 'CUS-003',
        title: 'Delta Stores',
        subtitle: 'Wholesale account · Alexandria',
        cells: [
          'Delta Stores',
          '01000000103',
          'Alexandria',
          '38',
          '24,800 EGP'
        ],
        status: UiLabel('On hold', 'موقوف'),
        tone: ErpStatusTone.warning),
    ErpRecordView(
        id: 'CUS-004',
        title: 'أحمد محمود',
        subtitle: 'عميل تجزئة · القاهرة',
        cells: ['أحمد محمود', '01000000104', 'Cairo', '9', '1,250 EGP'],
        status: UiLabel('Active', 'نشط'),
        tone: ErpStatusTone.success)
  ],
  fields: [
    ErpFieldSpec(UiLabel('Full name', 'الاسم الكامل'), wide: false),
    ErpFieldSpec(UiLabel('Phone', 'رقم الهاتف'), wide: false),
    ErpFieldSpec(UiLabel('Email', 'البريد الإلكتروني'), wide: false),
    ErpFieldSpec(UiLabel('City', 'المدينة'), wide: false),
    ErpFieldSpec(UiLabel('Address', 'العنوان'), wide: true),
    ErpFieldSpec(UiLabel('Credit limit', 'الحد الائتماني'), wide: false),
    ErpFieldSpec(UiLabel('Notes', 'ملاحظات'), wide: true)
  ],
  filters: [
    UiLabel('All', 'الكل'),
    UiLabel('Active', 'نشط'),
    UiLabel('On hold', 'موقوف')
  ],
);
