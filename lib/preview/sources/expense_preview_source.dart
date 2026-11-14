import 'package:bayaa_pos/preview/data/preview_data.dart';
import 'package:bayaa_pos/features/expenses/presentation/models/expense_view_data.dart';

class ExpensePreviewSource {
  Future<List<ExpenseViewData>> getExpenses(
          {DateTime? start, DateTime? end}) async =>
      PreviewData.expenses
          .where((e) =>
              (start == null || !e.date.isBefore(start)) &&
              (end == null || !e.date.isAfter(end)))
          .toList();
  Future<double> total(DateTime start, DateTime end) async =>
      (await getExpenses(start: start, end: end))
          .fold<double>(0.0, (sum, e) => sum + e.amount);
}
