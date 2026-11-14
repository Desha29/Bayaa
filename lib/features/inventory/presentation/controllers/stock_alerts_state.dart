// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bayaa_pos/features/products/presentation/models/product_view_data.dart';

class StockAlertsState {}

class StockLoadedState extends StockAlertsState {
  List<ProductViewData> products;
  StockLoadedState({
    required this.products,
  });
}

class StockLoadingState extends StockAlertsState {}

class StockErrorState extends StockAlertsState {
  String msg;
  StockErrorState(this.msg);
}
