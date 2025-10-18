import 'package:equatable/equatable.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/models/sale_model.dart';

abstract class SalesState extends Equatable {
  const SalesState();

  @override
  List<Object?> get props => [];
}

class SalesInitial extends SalesState {}

class SalesLoading extends SalesState {}

class SalesLoaded extends SalesState {
  final List<CartItemModel> cartItems;
  final List<Sale> recentSales;
  final double totalAmount;
  final String? scannerMessage;

  const SalesLoaded({
    required this.cartItems,
    required this.recentSales,
    required this.totalAmount,
    this.scannerMessage,
  });

  @override
  List<Object?> get props => [cartItems, recentSales, totalAmount, scannerMessage];
}

class SalesError extends SalesState {
  final String message;

  const SalesError({required this.message});

  @override
  List<Object?> get props => [message];
}

class CheckoutSuccess extends SalesState {
  final String message;
  final double total;

  const CheckoutSuccess({
    required this.message,
    required this.total,
  });

  @override
  List<Object?> get props => [message, total];
}

class CheckoutSuccessWithSale extends CheckoutSuccess {
  final Sale sale;

  const CheckoutSuccessWithSale({
    required super.message,
    required super.total,
    required this.sale,
  });

  @override
  List<Object?> get props => [message, total, sale];
}

class PriceValidationError extends SalesState {
  final String message;
  final double minPrice;
  final double attemptedPrice;

  const PriceValidationError({
    required this.message,
    required this.minPrice,
    required this.attemptedPrice,
  });

  @override
  List<Object?> get props => [message, minPrice, attemptedPrice];
}
