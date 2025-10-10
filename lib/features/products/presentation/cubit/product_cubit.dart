import 'package:crazy_phone_pos/features/products/data/models/product_model.dart';
import 'package:crazy_phone_pos/features/products/domain/product_repository_int.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'product_states.dart';

class ProductCubit extends Cubit<ProductStates> {
  ProductCubit({required this.productRepositoryInt})
      : super(ProductInitialState());
  static ProductCubit get(context) => BlocProvider.of(context);
  ProductRepositoryInt productRepositoryInt;
  List<Product> products = [];
  List<String> categories = [];
  void getAllProducts() {
    emit(ProductLoadingState());
    final result = productRepositoryInt.getAllProduct();
    result.fold(
      (failure) => emit(ProductErrorState(failure.message)),
      (productsList) {
        products = productsList;
        emit(ProductLoadedState(productsList));
      },
    );
  }

  void saveProduct(Product product) {
    emit(ProductLoadingState());
    final result = productRepositoryInt.saveProduct(product);
    result.fold(
      (failure) => emit(ProductErrorState(failure.message)),
      (_) {
        emit(ProductSuccessState());
        getAllProducts();
      },
    );
  }

  void deleteProduct(String barcode) {
    emit(ProductLoadingState());
    final result = productRepositoryInt.deleteProduct(barcode);
    result.fold(
      (failure) => emit(ProductErrorState(failure.message)),
      (_) {
        emit(ProductSuccessState());
        getAllProducts();
      },
    );
  }

  void filterByCategory(String category) {
    if (category == 'الكل') {
      getAllProducts();
      return;
    }
    final filteredProducts =
        products.where((product) => product.category == category).toList();
    emit(ProductLoadedState(filteredProducts));
  }

  void searchProducts(String query) {
    if (query.isEmpty) {
      getAllProducts();
      return;
    }
    final filteredProducts = products
        .where((product) =>
            product.name.toLowerCase().contains(query.toLowerCase()) ||
            product.barcode.toLowerCase().contains(query.toLowerCase()) ||
            product.category.toLowerCase().contains(query.toLowerCase()))
        .toList();
    emit(ProductLoadedState(filteredProducts));
  }

  void getAllCategories() async {
    await Future.delayed(const Duration(milliseconds: 200));
    final result = productRepositoryInt.getAllCategory();
    result.fold(
      (failure) => emit(CategoryErrorState(failure.message)),
      (categoriesList) {
        categories = categoriesList;
        emit(CategoryLoadedState(categoriesList));
      },
    );
  }

  void saveCategory(String category) {
    emit(ProductLoadingState());
    final result = productRepositoryInt.saveCategory(category);
    result.fold(
      (failure) => emit(CategoryErrorState(failure.message)),
      (_) {
        emit(CategorySuccessState());
        getAllCategories();
      },
    );
  }

  void deleteCategory(String category) {
    emit(ProductLoadingState());
    final result = productRepositoryInt.deleteCategory(category);
    result.fold(
      (failure) => emit(CategoryErrorState(failure.message)),
      (_) {
        emit(CategorySuccessState());
        getAllCategories();
      },
    );
  }
}
