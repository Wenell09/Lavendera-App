part of 'customer_action_bloc.dart';

abstract class CustomerActionState {}

final class CustomerActionInitial extends CustomerActionState {}

final class CustomerActionLoading extends CustomerActionState {}

final class CustomerActionSuccess extends CustomerActionState {
  final String message;

  CustomerActionSuccess({required this.message});
}

final class CustomerActionError extends CustomerActionState {
  final String message;

  CustomerActionError({required this.message});
}
