import 'package:bayaa_pos/preview/data/feature_chart_examples.dart';
import 'package:flutter/material.dart';
import 'package:bayaa_pos/shared/widgets/erp/erp_module_screen.dart';
import '../views/customers_view.dart';

class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});
  @override
  Widget build(BuildContext context) => Builder(builder: (context) {
        Theme.of(context);
        return ErpModuleScreen(
            spec: customersView, insights: featureChartExamples('customers'));
      });
}
