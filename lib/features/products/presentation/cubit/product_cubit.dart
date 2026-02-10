import 'package:crazy_phone_pos/core/error/failure.dart';
import 'package:crazy_phone_pos/features/products/data/models/product_model.dart';
import 'package:crazy_phone_pos/features/products/domain/product_repository_int.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../core/services/activity_logger.dart';
import '../../../../core/data/models/activity_log.dart';
import '../../../auth/presentation/cubit/user_cubit.dart';
import '../../../notifications/presentation/cubit/notifications_cubit.dart';
import 'product_states.dart';

class ProductCubit extends Cubit<ProductStates> {
  ProductCubit({required this.productRepositoryInt})
      : super(ProductInitialState());
  static ProductCubit get(context) => BlocProvider.of(context);
  ProductRepositoryInt productRepositoryInt;
  List<Product> products = [];
  List<Product> get allProducts => products;
  List<String> categories = [];
  String selectedCategory = 'الكل';
  String selectedAvailability = 'الكل';
  
  String currentSearchQuery = '';

  // Pagination state
  int currentPage = 0;
  bool hasMoreProducts = true;
  bool isLoadingMore = false;
  static const int pageSize = 50;

  void clearProducts() {
    products = [];
    currentPage = 0;
    hasMoreProducts = true;
    currentSearchQuery = '';
    selectedCategory = 'الكل';
    selectedAvailability = 'الكل';
    emit(ProductLoadedState([]));
  }

  void getAllProducts() async {
    emit(ProductLoadingState());
    
    // Reset pagination
    currentPage = 0;
    hasMoreProducts = true;
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
      (failure) => emit(ProductErrorState(failure.message)),
      (productsList) {
        products = productsList;
        hasMoreProducts = productsList.length >= pageSize;
        emit(ProductLoadedState(productsList));
      },
    );
  }
  
  void loadMoreProducts() async {
    if (isLoadingMore || !hasMoreProducts) return;
    
    isLoadingMore = true;
    emit(ProductLoadedState(products)); // Emit to show execution loading indicator
    currentPage++;
    
    final result = await productRepositoryInt.getProductsPaginated(
      page: currentPage,
      pageSize: pageSize,
      category: selectedCategory,
      availability: selectedAvailability,
      searchQuery: currentSearchQuery,
    );
    
    result.fold(
      (failure) {
        isLoadingMore = false;
        currentPage--; // Revert page increment on error
      },
      (productsList) {
        products.addAll(productsList);
        hasMoreProducts = productsList.length >= pageSize;
        isLoadingMore = false;
        emit(ProductLoadedState(products));
      },
    );
  }

  void saveProduct(Product product) async {
    emit(ProductLoadingState());
    final result = await productRepositoryInt.saveProduct(product);
    result.fold(
      (failure) => emit(ProductErrorState(failure.message)),
      (_) {
        emit(ProductSuccessState("تم حفظ المنتج بنجاح"));
        
        // Determine activity type
        final isUpdate = products.any((p) => p.barcode == product.barcode);
        
        // Log activity
        getIt<ActivityLogger>().logActivity(
          type: isUpdate ? ActivityType.productUpdate : ActivityType.productAdd,
          description: isUpdate ? 'تحديث منتج: ${product.name}' : 'إضافة منتج: ${product.name}',
          userName: getIt<UserCubit>().currentUser.name,
          details: {'barcode': product.barcode, 'price': product.price},
        );
        
        getAllProducts();
      },
    );
  }

  void deleteProduct(String barcode) async {
    emit(ProductLoadingState());
    final result = await productRepositoryInt.deleteProduct(barcode);
    result.fold(
      (failure) => emit(ProductErrorState(failure.message)),
      (_) {
        final deletedProduct = products.firstWhere((p) => p.barcode == barcode);
        
        emit(ProductSuccessState("تم حذف المنتج بنجاح"));
        
        // Log activity
        getIt<ActivityLogger>().logActivity(
          type: ActivityType.productDelete,
          description: 'حذف منتج: ${deletedProduct.name}',
          userName: getIt<UserCubit>().currentUser.name,
          details: {'barcode': barcode},
        );
        
        getAllProducts();
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
    await Future.delayed(const Duration(milliseconds: 200));
    final result = await productRepositoryInt.getAllCategory();
    result.fold(
      (failure) => emit(CategoryErrorState(failure.message)),
      (categoriesList) {
        categories = categoriesList;
        emit(CategoryLoadedState(categoriesList));
      },
    );
  }

  void saveCategory(String category) async {
    emit(ProductLoadingState());
    final result = await productRepositoryInt.saveCategory(category);
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
      String? newCategory}) async {
    emit(ProductLoadingState());
    final result = await productRepositoryInt.deleteCategory(
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

  Future<bool> checkProductExists(String barcode) async {
    final result = await productRepositoryInt.productExists(barcode);
    return result.fold((l) => false, (exists) => exists);
  }
}
