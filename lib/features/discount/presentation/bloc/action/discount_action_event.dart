part of 'discount_action_bloc.dart';

abstract class DiscountActionEvent {}

class CreateDiscountActionRequest extends DiscountActionEvent {
  final Map<String, dynamic> body;

  CreateDiscountActionRequest({required this.body});
}

class UpdateDiscountActionRequest extends DiscountActionEvent {
  final String id;
  final Map<String, dynamic> body;

  UpdateDiscountActionRequest({required this.id, required this.body});
}

class DeleteDiscountActionRequest extends DiscountActionEvent {
  final String id;

  DeleteDiscountActionRequest({required this.id});
}
