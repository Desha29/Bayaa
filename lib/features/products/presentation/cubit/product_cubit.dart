import 'package:crazy_phone_pos/core/error/failure.dart';
import 'package:crazy_phone_pos/features/products/data/models/product_model.dart';
import 'package:crazy_phone_pos/features/products/domain/product_repository_int.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../notifications/presentation/cubit/notifications_cubit.dart';
import 'product_states.dart';

class ProductCubit extends Cubit<ProductStates> {
  ProductCubit({required this.productRepositoryInt})
      : super(ProductInitialState());
  static ProductCubit get(context) => BlocProvider.of(context);
  ProductRepositoryInt productRepositoryInt;
  List<Product> products = [];
  List<String> categories = [];
  String selectedCategory = 'الكل';
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
        emit(ProductSuccessState("تم العملية بنجاح"));
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
        emit(ProductSuccessState("تم الحذف  بنجاح"));
        getAllProducts();
      },
    );
  }

  void filterByCategory(String category) {
    if (category == 'الكل') {
      getAllProducts();
      return;
    }
    selectedCategory = category;
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
        emit(CategorySuccessState("تمت الإضافة بنجاح"));
        getAllCategories();
      },
    );
  }

  void deleteCategory(
      {required String category,
      bool forceDelete = false,
      String? newCategory}) {
    emit(ProductLoadingState());
    final result = productRepositoryInt.deleteCategory(
        category: category, forceDelete: forceDelete, newCategory: newCategory);
    result.fold(
      (failure) {
        if (failure is CacheFailure) {
          emit(CategoryErrorDeleteState(failure.message, category));
        } else {
          emit(CategoryErrorState(failure.message));
        }
      },
      (_) {
        emit(CategorySuccessState("تم الحذف  بنجاح"));
        getAllCategories();
        getAllProducts();
      },
    );
  }
}
