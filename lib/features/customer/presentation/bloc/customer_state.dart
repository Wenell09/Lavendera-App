part of 'customer_bloc.dart';

class CustomerState {}

final class CustomerInitial extends CustomerState {}

final class CustomerLoading extends CustomerState {}

final class CustomerPaginationLoading extends CustomerState {
  final List<Customer> customers;
  final int currentPage;
  final bool hasMorePages;
  CustomerPaginationLoading({
    required this.customers,
    required this.currentPage,
    required this.hasMorePages,
  });
}

final class CustomerLoaded extends CustomerState {
  final List<Customer> customers;
  final int currentPage;
  final bool hasMorePages;
  CustomerLoaded({
    required this.customers,
    required this.currentPage,
    required this.hasMorePages,
  });
}

final class CustomerActionSuccess extends CustomerState {
  final String message;
  CustomerActionSuccess({required this.message});
}

final class CustomerActionError extends CustomerState {
  final String message;
  CustomerActionError({required this.message});
}

final class CustomerError extends CustomerState {
  final String message;
  final List<Customer>? cachedCustomers;
  CustomerError({required this.message, this.cachedCustomers});
}
