part of 'outlet_payment_method_action_bloc.dart';

abstract class OutletPaymentMethodActionEvent {}

class CreateOutletPaymentMethodActionRequest extends OutletPaymentMethodActionEvent {
  final String outletId;
  final Map<String, dynamic> body;

  CreateOutletPaymentMethodActionRequest({
    required this.outletId,
    required this.body,
  });
}

class UpdateOutletPaymentMethodActionRequest extends OutletPaymentMethodActionEvent {
  final String outletId;
  final String paymentMethodId;
  final Map<String, dynamic> body;

  UpdateOutletPaymentMethodActionRequest({
    required this.outletId,
    required this.paymentMethodId,
    required this.body,
  });
}

class DeleteOutletPaymentMethodActionRequest extends OutletPaymentMethodActionEvent {
  final String outletId;
  final String paymentMethodId;

  DeleteOutletPaymentMethodActionRequest({
    required this.outletId,
    required this.paymentMethodId,
  });
}
