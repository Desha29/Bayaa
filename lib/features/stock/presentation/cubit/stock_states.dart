// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:crazy_phone_pos/features/products/data/models/product_model.dart';

class StockStates {}

class StockSucssesState extends StockStates {
  List<Product> products;
  StockSucssesState({
    required this.products,
  });
}

class StockLoadingState extends StockStates{}

class StockErrorState extends StockStates{
  String msg;
  StockErrorState(this.msg);
}
