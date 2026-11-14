import 'package:bayaa_pos/preview/data/feature_chart_examples.dart';
import 'package:flutter/material.dart';
import 'package:bayaa_pos/shared/widgets/erp/erp_module_screen.dart';
import '../views/purchase_returns_view.dart';

class PurchaseReturnsScreen extends StatelessWidget {
  const PurchaseReturnsScreen({super.key});
  @override
  Widget build(BuildContext context) => Builder(builder: (context) {
        Theme.of(context);
        return ErpModuleScreen(
            spec: purchaseReturnsView,
            insights: featureChartExamples('purchase_returns'));
      });
}
