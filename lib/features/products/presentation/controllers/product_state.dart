import 'package:bayaa_pos/features/products/presentation/models/product_view_data.dart';

class ProductState {}

class ProductInitialState extends ProductState {}

class ProductLoadingState extends ProductState {}

class ProductLoadedState extends ProductState {
  final List<ProductViewData> products;
  ProductLoadedState(this.products);
}

class ProductErrorState extends ProductState {
  final String message;
  ProductErrorState(this.message);
}

class ProductSuccessState extends ProductState {
  String msg;
  ProductSuccessState(this.msg);
}

class CategoryLoadedState extends ProductState {
  final List<String> categories;
  CategoryLoadedState(this.categories);
}

class CategoryErrorState extends ProductState {
  final String message;
  CategoryErrorState(this.message);
}

class CategoryErrorDeleteState extends ProductState {
  final String message;
  final String category;
  CategoryErrorDeleteState(this.message, this.category);
}

class CategorySuccessState extends ProductState {
  String msg;
  CategorySuccessState(this.msg);
}
