part of 'outlet_payment_method_action_bloc.dart';

abstract class OutletPaymentMethodActionState {}

class OutletPaymentMethodActionInitial extends OutletPaymentMethodActionState {}

class OutletPaymentMethodActionLoading extends OutletPaymentMethodActionState {}

class OutletPaymentMethodActionSuccess extends OutletPaymentMethodActionState {
  final String message;
  final OutletPaymentMethod? paymentMethod;

  OutletPaymentMethodActionSuccess({
    required this.message,
    this.paymentMethod,
  });
}

class OutletPaymentMethodActionError extends OutletPaymentMethodActionState {
  final String message;

  OutletPaymentMethodActionError({required this.message});
}
