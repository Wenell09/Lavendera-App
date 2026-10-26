part of 'order_bloc.dart';

abstract class OrderState {}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderLoaded extends OrderState {
  final List<OrderEntity> orders;
  final int currentPage;
  final bool hasMorePages;
  final String? activeStatus;
  final String? searchQuery;

  OrderLoaded({
    required this.orders,
    required this.currentPage,
    required this.hasMorePages,
    this.activeStatus,
    this.searchQuery,
  });
}

class OrderPaginationLoading extends OrderState {
  final List<OrderEntity> orders;
  final int currentPage;
  final bool hasMorePages;

  OrderPaginationLoading({
    required this.orders,
    required this.currentPage,
    required this.hasMorePages,
  });
}

class OrderError extends OrderState {
  final String message;
  final List<OrderEntity>? cachedOrders;

  OrderError({
    required this.message,
    this.cachedOrders,
  });
}
