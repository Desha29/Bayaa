import 'dart:async';
import 'package:bayaa_pos/features/products/presentation/models/product_view_data.dart';
import 'package:bayaa_pos/features/products/presentation/sources/product_catalog_source.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bayaa_pos/features/products/presentation/controllers/product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  ProductCubit({required this.productRepositoryInt})
      : super(ProductInitialState());

  static ProductCubit get(context) => BlocProvider.of(context);
  ProductCatalogSource productRepositoryInt;
  List<ProductViewData> products = [];
  List<ProductViewData> get allProducts => products;
  List<String> categories = [];
  String selectedCategory = '*';
  String selectedAvailability = '*';

  String currentSearchQuery = '';

  // Pagination state
  int currentPage = 0;
  bool hasMoreProducts = true;
  bool isLoadingMore = false;
  static const int pageSize = 50;
  int _requestVersion = 0;

  void clearProducts() {
    products = [];
    currentPage = 0;
    hasMoreProducts = true;
    currentSearchQuery = '';
    selectedCategory = '*';
    selectedAvailability = '*';
    emit(ProductLoadedState([]));
  }

  Future<void> getAllProducts() async {
    final requestVersion = ++_requestVersion;
    emit(ProductLoadingState());

    // Reset pagination
    currentPage = 0;
    hasMoreProducts = true;
    isLoadingMore = false;
    products = [];

    // Load first page
    final result = await productRepositoryInt.getProductsPaginated(
      page: currentPage,
      pageSize: pageSize,
      category: selectedCategory,
      availability: selectedAvailability,
      searchQuery: currentSearchQuery,
    );

    result.fold(
      (failure) {
        if (requestVersion == _requestVersion) {
          emit(ProductErrorState(failure.message));
        }
      },
      (productsList) {
        if (requestVersion != _requestVersion) return;
        products = List<ProductViewData>.from(productsList);
        hasMoreProducts = productsList.length == pageSize;
        emit(ProductLoadedState(List<ProductViewData>.unmodifiable(products)));
      },
    );
  }

  void loadMoreProducts() async {
    if (isLoadingMore || !hasMoreProducts) return;

    final requestVersion = _requestVersion;
    final nextPage = currentPage + 1;
    isLoadingMore = true;
    emit(ProductLoadedState(List<ProductViewData>.unmodifiable(products)));

    final result = await productRepositoryInt.getProductsPaginated(
      page: nextPage,
      pageSize: pageSize,
      category: selectedCategory,
      availability: selectedAvailability,
      searchQuery: currentSearchQuery,
    );

    result.fold(
      (failure) {
        if (requestVersion != _requestVersion) return;
        isLoadingMore = false;
        emit(ProductErrorState(failure.message));
        emit(ProductLoadedState(List<ProductViewData>.unmodifiable(products)));
      },
      (productsList) {
        if (requestVersion != _requestVersion) return;
        final existingBarcodes = products.map((p) => p.barcode).toSet();
        products.addAll(
          productsList.where((p) => existingBarcodes.add(p.barcode)),
        );
        currentPage = nextPage;
        hasMoreProducts = productsList.length == pageSize;
        isLoadingMore = false;
        emit(ProductLoadedState(List<ProductViewData>.unmodifiable(products)));
      },
    );
  }

  void filterByCategory(String category) {
    selectedCategory = category;
    getAllProducts();
  }

  void filterByAvailability(String availability) {
    selectedAvailability = availability;
    getAllProducts();
  }

  void searchProducts(String query) {
    currentSearchQuery = query;
    getAllProducts();
  }

  void getAllCategories() async {
    final result = await productRepositoryInt.getAllCategory();
    result.fold(
      (failure) => emit(CategoryErrorState(failure.message)),
      (categoriesList) {
        categories = categoriesList;
        emit(CategoryLoadedState(categoriesList));
      },
    );
  }
}
