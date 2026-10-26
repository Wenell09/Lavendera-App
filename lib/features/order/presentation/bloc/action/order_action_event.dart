part of 'order_action_bloc.dart';

abstract class OrderActionEvent {}

class CreateOrderActionRequest extends OrderActionEvent {
  final Map<String, dynamic> body;

  CreateOrderActionRequest({required this.body});
}

class UpdateOrderStatusActionRequest extends OrderActionEvent {
  final String id;
  final String status;

  UpdateOrderStatusActionRequest({
    required this.id,
    required this.status,
  });
}

class CancelOrderActionRequest extends OrderActionEvent {
  final String id;

  CancelOrderActionRequest({required this.id});
}

class ConfirmPaymentActionRequest extends OrderActionEvent {
  final String orderId;
  final String paymentId;

  ConfirmPaymentActionRequest({
    required this.orderId,
    required this.paymentId,
  });
}

class InputCashPaymentActionRequest extends OrderActionEvent {
  final String orderId;
  final num paidAmount;

  InputCashPaymentActionRequest({
    required this.orderId,
    required this.paidAmount,
  });
}
