part of 'customer_detail_bloc.dart';

abstract class CustomerDetailState {}

class CustomerDetailInitial extends CustomerDetailState {}

class CustomerDetailLoading extends CustomerDetailState {}

class CustomerDetailLoaded extends CustomerDetailState {
  final Customer customer;
  CustomerDetailLoaded({required this.customer});
}

class CustomerDetailError extends CustomerDetailState {
  final String message;
  CustomerDetailError({required this.message});
}
