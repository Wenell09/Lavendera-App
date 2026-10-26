part of 'order_detail_bloc.dart';

abstract class OrderDetailState {}

class OrderDetailInitial extends OrderDetailState {}

class OrderDetailLoading extends OrderDetailState {}

class OrderDetailLoaded extends OrderDetailState {
  final OrderEntity order;

  OrderDetailLoaded({required this.order});
}

class OrderDetailError extends OrderDetailState {
  final String message;

  OrderDetailError({required this.message});
}
