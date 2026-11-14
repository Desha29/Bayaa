import 'package:flutter/material.dart';
import 'package:bayaa_pos/shared/widgets/erp/erp_view_spec.dart';

// Display examples only; this feature has no business model or persistence.
final warehousesView = ErpViewSpec(
  id: 'warehouses',
  title: UiLabel('Stores & warehouses', 'الفروع والمخازن'),
  subtitle: UiLabel(
      'Branch directory, storage locations, and stock distribution',
      'دليل الفروع ومواقع التخزين وتوزيع المخزون'),
  icon: Icons.warehouse_outlined,
  action: UiLabel('Add location', 'إضافة موقع'),
  columns: [
    UiLabel('Location', 'الموقع'),
    UiLabel('Type', 'النوع'),
    UiLabel('City', 'المدينة'),
    UiLabel('Manager', 'المسؤول'),
    UiLabel('Products', 'المنتجات')
  ],
  metrics: [
    ErpMetricSpec(
        UiLabel('Locations', 'المواقع'), '4', Icons.warehouse_outlined),
    ErpMetricSpec(UiLabel('Retail branches', 'فروع البيع'), '3',
        Icons.storefront_outlined),
    ErpMetricSpec(
        UiLabel('Warehouses', 'المخازن'), '1', Icons.inventory_2_outlined),
    ErpMetricSpec(UiLabel('Storage utilization', 'استخدام السعة'), '68%',
        Icons.space_dashboard_outlined)
  ],
  records: [
    ErpRecordView(
        id: 'LOC-001',
        title: 'Main warehouse',
        subtitle: 'Central storage · Cairo',
        cells: ['Main warehouse', 'Warehouse', 'Cairo', 'أحمد محمد', '1,240'],
        status: UiLabel('Active', 'نشط'),
        tone: ErpStatusTone.success),
    ErpRecordView(
        id: 'LOC-002',
        title: 'Cairo store',
        subtitle: 'Retail branch · Nasr City',
        cells: ['Cairo store', 'Retail', 'Cairo', 'سارة علي', '684'],
        status: UiLabel('Active', 'نشط'),
        tone: ErpStatusTone.success),
    ErpRecordView(
        id: 'LOC-003',
        title: 'Giza store',
        subtitle: 'Retail branch · Giza',
        cells: ['Giza store', 'Retail', 'Giza', 'عمر حسن', '426'],
        status: UiLabel('Active', 'نشط'),
        tone: ErpStatusTone.success),
    ErpRecordView(
        id: 'LOC-004',
        title: 'Alexandria store',
        subtitle: 'Retail branch · Alexandria',
        cells: ['Alexandria store', 'Retail', 'Alexandria', 'مريم حسن', '312'],
        status: UiLabel('Maintenance', 'صيانة'),
        tone: ErpStatusTone.warning)
  ],
  fields: [
    ErpFieldSpec(UiLabel('Location name', 'اسم الموقع'), wide: false),
    ErpFieldSpec(UiLabel('Location type', 'نوع الموقع'), wide: false),
    ErpFieldSpec(UiLabel('City', 'المدينة'), wide: false),
    ErpFieldSpec(UiLabel('Manager', 'مسؤول الموقع'), wide: false),
    ErpFieldSpec(UiLabel('Phone', 'الهاتف'), wide: false),
    ErpFieldSpec(UiLabel('Capacity', 'السعة'), wide: false),
    ErpFieldSpec(UiLabel('Address', 'العنوان'), wide: true),
    ErpFieldSpec(UiLabel('Notes', 'ملاحظات'), wide: true)
  ],
  filters: [
    UiLabel('All', 'الكل'),
    UiLabel('Active', 'نشط'),
    UiLabel('Maintenance', 'صيانة')
  ],
);
