import 'package:crazy_phone_pos/features/products/data/models/product_model.dart';

class ProductStates {}

class ProductInitialState extends ProductStates {}

class ProductLoadingState extends ProductStates {}

class ProductLoadedState extends ProductStates {
  final List<Product> products;
  ProductLoadedState(this.products);
}

class ProductErrorState extends ProductStates {
  final String message;
  ProductErrorState(this.message);
}

class ProductSuccessState extends ProductStates {
  String msg;
  ProductSuccessState(this.msg);
}

class CategoryLoadedState extends ProductStates {
  final List<String> categories;
  CategoryLoadedState(this.categories);
}

class CategoryErrorState extends ProductStates {
  final String message;
  CategoryErrorState(this.message);
}

class CategorySuccessState extends ProductStates {}
