part of 'customer_action_bloc.dart';

abstract class CustomerActionEvent {}

class CreateCustomerActionRequest extends CustomerActionEvent {
  final Map<String, dynamic> body;

  CreateCustomerActionRequest({required this.body});
}

class UpdateCustomerActionRequest extends CustomerActionEvent {
  final String id;
  final Map<String, dynamic> body;

  UpdateCustomerActionRequest({required this.id, required this.body});
}

class DeleteCustomerActionRequest extends CustomerActionEvent {
  final String id;

  DeleteCustomerActionRequest({required this.id});
}
