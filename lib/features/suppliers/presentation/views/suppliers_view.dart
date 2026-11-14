import 'package:flutter/material.dart';
import 'package:bayaa_pos/shared/widgets/erp/erp_view_spec.dart';

// Display examples only; this feature has no business model or persistence.
final suppliersView = ErpViewSpec(
  id: 'suppliers',
  title: UiLabel('Suppliers', 'الموردون'),
  subtitle: UiLabel(
      'Supplier directory, purchase contacts, and account overview',
      'دليل الموردين وجهات اتصال المشتريات وملخص الحسابات'),
  icon: Icons.local_shipping_outlined,
  action: UiLabel('Add supplier', 'إضافة مورد'),
  columns: [
    UiLabel('Supplier', 'المورد'),
    UiLabel('Contact', 'جهة الاتصال'),
    UiLabel('Category', 'التصنيف'),
    UiLabel('Payables', 'المستحقات'),
    UiLabel('Last order', 'آخر طلب')
  ],
  metrics: [
    ErpMetricSpec(
        UiLabel('Suppliers', 'الموردون'), '36', Icons.local_shipping_outlined),
    ErpMetricSpec(UiLabel('Active partners', 'شركاء نشطون'), '32',
        Icons.handshake_outlined),
    ErpMetricSpec(UiLabel('Payables', 'مستحقات الموردين'), '92,600 EGP',
        Icons.payments_outlined),
    ErpMetricSpec(UiLabel('Orders this month', 'طلبات الشهر'), '48',
        Icons.inventory_2_outlined)
  ],
  records: [
    ErpRecordView(
        id: 'SUP-001',
        title: 'شركة النيل للتوريدات',
        subtitle: 'توريدات البقالة والمواد الغذائية',
        cells: [
          'شركة النيل للتوريدات',
          '01000000201',
          'Grocery',
          '32,500 EGP',
          'PO-0048'
        ],
        status: UiLabel('Active', 'نشط'),
        tone: ErpStatusTone.success),
    ErpRecordView(
        id: 'SUP-002',
        title: 'Delta Dairy',
        subtitle: 'Dairy & chilled products',
        cells: ['Delta Dairy', '01000000202', 'Dairy', '18,900 EGP', 'PO-0047'],
        status: UiLabel('Active', 'نشط'),
        tone: ErpStatusTone.success),
    ErpRecordView(
        id: 'SUP-003',
        title: 'Cairo Packaging',
        subtitle: 'Packaging supplies',
        cells: [
          'Cairo Packaging',
          '01000000203',
          'Supplies',
          '4,200 EGP',
          'PO-0041'
        ],
        status: UiLabel('Pending', 'قيد الانتظار'),
        tone: ErpStatusTone.warning),
    ErpRecordView(
        id: 'SUP-004',
        title: 'المتحدة للمشروبات',
        subtitle: 'مورد مشروبات ومياه معدنية',
        cells: [
          'المتحدة للمشروبات',
          '01000000204',
          'Beverages',
          '37,000 EGP',
          'PO-0046'
        ],
        status: UiLabel('Active', 'نشط'),
        tone: ErpStatusTone.success)
  ],
  fields: [
    ErpFieldSpec(UiLabel('Company name', 'اسم الشركة'), wide: false),
    ErpFieldSpec(UiLabel('Contact person', 'مسؤول التواصل'), wide: false),
    ErpFieldSpec(UiLabel('Phone', 'الهاتف'), wide: false),
    ErpFieldSpec(UiLabel('Email', 'البريد الإلكتروني'), wide: false),
    ErpFieldSpec(UiLabel('Tax number', 'الرقم الضريبي'), wide: false),
    ErpFieldSpec(UiLabel('Payment terms', 'شروط الدفع'), wide: false),
    ErpFieldSpec(UiLabel('Address & notes', 'العنوان والملاحظات'), wide: true)
  ],
  filters: [
    UiLabel('All', 'الكل'),
    UiLabel('Active', 'نشط'),
    UiLabel('Pending', 'قيد الانتظار')
  ],
);
