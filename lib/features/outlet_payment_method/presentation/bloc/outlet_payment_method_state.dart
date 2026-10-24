part of 'outlet_payment_method_bloc.dart';

abstract class OutletPaymentMethodState {}

class OutletPaymentMethodInitial extends OutletPaymentMethodState {}

class OutletPaymentMethodLoading extends OutletPaymentMethodState {}

class OutletPaymentMethodLoaded extends OutletPaymentMethodState {
  final List<OutletPaymentMethod> paymentMethods;
  final int currentPage;
  final bool hasMorePages;

  OutletPaymentMethodLoaded({
    required this.paymentMethods,
    required this.currentPage,
    required this.hasMorePages,
  });
}

class OutletPaymentMethodPaginationLoading extends OutletPaymentMethodState {
  final List<OutletPaymentMethod> paymentMethods;
  final int currentPage;
  final bool hasMorePages;

  OutletPaymentMethodPaginationLoading({
    required this.paymentMethods,
    required this.currentPage,
    required this.hasMorePages,
  });
}

class OutletPaymentMethodError extends OutletPaymentMethodState {
  final String message;
  final List<OutletPaymentMethod>? cachedPaymentMethods;

  OutletPaymentMethodError({
    required this.message,
    this.cachedPaymentMethods,
  });
}
