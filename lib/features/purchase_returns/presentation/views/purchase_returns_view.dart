import 'package:flutter/material.dart';
import 'package:bayaa_pos/shared/widgets/erp/erp_view_spec.dart';

// Display examples only; this feature has no business model or persistence.
final purchaseReturnsView = ErpViewSpec(
  id: 'purchase_returns',
  title: UiLabel('Purchase returns', 'مرتجعات المشتريات'),
  subtitle: UiLabel('Supplier return documents and linked purchase invoices',
      'مستندات المرتجعات للموردين وفواتير الشراء المرتبطة'),
  icon: Icons.assignment_return_outlined,
  action: UiLabel('New purchase return', 'مرتجع مشتريات جديد'),
  columns: [
    UiLabel('Return document', 'مستند المرتجع'),
    UiLabel('Supplier', 'المورد'),
    UiLabel('Original purchase', 'الشراء الأصلي'),
    UiLabel('Reason', 'السبب'),
    UiLabel('Value', 'القيمة')
  ],
  metrics: [
    ErpMetricSpec(UiLabel('Return documents', 'مستندات المرتجع'), '12',
        Icons.assignment_return_outlined),
    ErpMetricSpec(UiLabel('Return value', 'قيمة المرتجعات'), '8,750 EGP',
        Icons.currency_exchange),
    ErpMetricSpec(
        UiLabel('Pending review', 'بانتظار المراجعة'), '3', Icons.schedule),
    ErpMetricSpec(UiLabel('Completed', 'مكتمل'), '9', Icons.task_alt)
  ],
  records: [
    ErpRecordView(
        id: 'PR-0012',
        title: 'PR-0012',
        subtitle: 'Delta Dairy · Damaged packaging',
        cells: [
          'PR-0012',
          'Delta Dairy',
          'PO-0047',
          'Damaged packaging',
          '1,650 EGP'
        ],
        status: UiLabel('Pending', 'قيد الانتظار'),
        tone: ErpStatusTone.warning),
    ErpRecordView(
        id: 'PR-0011',
        title: 'PR-0011',
        subtitle: 'شركة النيل للتوريدات · Quality review',
        cells: [
          'PR-0011',
          'شركة النيل للتوريدات',
          'PO-0042',
          'Quality issue',
          '2,200 EGP'
        ],
        status: UiLabel('Completed', 'مكتمل'),
        tone: ErpStatusTone.success),
    ErpRecordView(
        id: 'PR-0010',
        title: 'PR-0010',
        subtitle: 'المتحدة للمشروبات · Delivery mismatch',
        cells: [
          'PR-0010',
          'المتحدة للمشروبات',
          'PO-0040',
          'Incorrect item',
          '950 EGP'
        ],
        status: UiLabel('Completed', 'مكتمل'),
        tone: ErpStatusTone.success),
    ErpRecordView(
        id: 'PR-0009',
        title: 'PR-0009',
        subtitle: 'Cairo Packaging · Sample draft',
        cells: [
          'PR-0009',
          'Cairo Packaging',
          'PO-0038',
          'Excess quantity',
          '450 EGP'
        ],
        status: UiLabel('Draft', 'مسودة'),
        tone: ErpStatusTone.warning)
  ],
  fields: [
    ErpFieldSpec(UiLabel('Original purchase invoice', 'فاتورة الشراء الأصلية'),
        wide: false),
    ErpFieldSpec(UiLabel('Supplier', 'المورد'), wide: false),
    ErpFieldSpec(UiLabel('Warehouse', 'المخزن'), wide: false),
    ErpFieldSpec(UiLabel('Return date', 'تاريخ المرتجع'), wide: false),
    ErpFieldSpec(UiLabel('Reason', 'سبب المرتجع'), wide: false),
    ErpFieldSpec(UiLabel('Items & quantities', 'الأصناف والكميات'), wide: true),
    ErpFieldSpec(UiLabel('Notes', 'ملاحظات'), wide: true)
  ],
  filters: [
    UiLabel('All', 'الكل'),
    UiLabel('Completed', 'مكتمل'),
    UiLabel('Pending', 'قيد الانتظار'),
    UiLabel('Draft', 'مسودة')
  ],
);
