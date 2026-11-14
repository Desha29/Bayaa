import 'package:flutter/material.dart';
import 'package:bayaa_pos/shared/widgets/erp/erp_view_spec.dart';

// Display examples only; this feature has no business model or persistence.
final purchasesView = ErpViewSpec(
  id: 'purchases',
  title: UiLabel('Purchases', 'المشتريات'),
  subtitle: UiLabel(
      'Purchase orders, supplier references, and receiving overview',
      'أوامر الشراء ومراجع الموردين ومتابعة الاستلام'),
  icon: Icons.shopping_bag_outlined,
  action: UiLabel('New purchase order', 'أمر شراء جديد'),
  columns: [
    UiLabel('Purchase order', 'أمر الشراء'),
    UiLabel('Supplier', 'المورد'),
    UiLabel('Warehouse', 'المخزن'),
    UiLabel('Order date', 'تاريخ الطلب'),
    UiLabel('Total', 'الإجمالي')
  ],
  metrics: [
    ErpMetricSpec(UiLabel('Purchase orders', 'أوامر الشراء'), '48',
        Icons.shopping_bag_outlined),
    ErpMetricSpec(UiLabel('Purchase value', 'قيمة المشتريات'), '185,400 EGP',
        Icons.payments_outlined),
    ErpMetricSpec(UiLabel('Awaiting receipt', 'بانتظار الاستلام'), '7',
        Icons.move_to_inbox_outlined),
    ErpMetricSpec(
        UiLabel('Draft orders', 'مسودات الطلبات'), '4', Icons.drafts_outlined)
  ],
  records: [
    ErpRecordView(
        id: 'PO-0048',
        title: 'PO-0048',
        subtitle: 'شركة النيل للتوريدات · Grocery restock',
        cells: [
          'PO-0048',
          'شركة النيل للتوريدات',
          'Main warehouse',
          '28 Oct',
          '24,800 EGP'
        ],
        status: UiLabel('Pending', 'قيد الانتظار'),
        tone: ErpStatusTone.warning),
    ErpRecordView(
        id: 'PO-0047',
        title: 'PO-0047',
        subtitle: 'Delta Dairy · Chilled delivery',
        cells: [
          'PO-0047',
          'Delta Dairy',
          'Cairo store',
          '27 Oct',
          '16,400 EGP'
        ],
        status: UiLabel('Received', 'مستلم'),
        tone: ErpStatusTone.success),
    ErpRecordView(
        id: 'PO-0046',
        title: 'PO-0046',
        subtitle: 'المتحدة للمشروبات · Weekly supplies',
        cells: [
          'PO-0046',
          'المتحدة للمشروبات',
          'Main warehouse',
          '26 Oct',
          '32,500 EGP'
        ],
        status: UiLabel('Received', 'مستلم'),
        tone: ErpStatusTone.success),
    ErpRecordView(
        id: 'PO-0045',
        title: 'PO-0045',
        subtitle: 'Cairo Packaging · Packaging supplies',
        cells: [
          'PO-0045',
          'Cairo Packaging',
          'Giza store',
          '25 Oct',
          '4,200 EGP'
        ],
        status: UiLabel('Draft', 'مسودة'),
        tone: ErpStatusTone.warning)
  ],
  fields: [
    ErpFieldSpec(UiLabel('Supplier', 'المورد'), wide: false),
    ErpFieldSpec(UiLabel('Warehouse', 'المخزن'), wide: false),
    ErpFieldSpec(UiLabel('Supplier reference', 'مرجع المورد'), wide: false),
    ErpFieldSpec(UiLabel('Order date', 'تاريخ الطلب'), wide: false),
    ErpFieldSpec(UiLabel('Payment terms', 'شروط الدفع'), wide: false),
    ErpFieldSpec(UiLabel('Expected delivery', 'الاستلام المتوقع'), wide: false),
    ErpFieldSpec(UiLabel('Items & quantities', 'الأصناف والكميات'), wide: true),
    ErpFieldSpec(UiLabel('Notes', 'ملاحظات'), wide: true)
  ],
  filters: [
    UiLabel('All', 'الكل'),
    UiLabel('Received', 'مستلم'),
    UiLabel('Pending', 'قيد الانتظار'),
    UiLabel('Draft', 'مسودة')
  ],
);
