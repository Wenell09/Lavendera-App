part of 'order_action_bloc.dart';

abstract class OrderActionState {}

class OrderActionInitial extends OrderActionState {}

class OrderActionLoading extends OrderActionState {}

class OrderActionSuccess extends OrderActionState {
  final String message;
  final OrderEntity order;

  OrderActionSuccess({
    required this.message,
    required this.order,
  });
}

class OrderActionError extends OrderActionState {
  final String message;

  OrderActionError({required this.message});
}
