part of 'customer_bloc.dart';

class CustomerEvent {}

class GetCustomersRequest extends CustomerEvent {
  final String? search;
  final int page;
  final int limit;

  GetCustomersRequest({this.search, this.page = 1, this.limit = 10});
}

class CreateCustomerRequest extends CustomerEvent {
  final Map<String, dynamic> body;
  CreateCustomerRequest({required this.body});
}

class UpdateCustomerRequest extends CustomerEvent {
  final String id;
  final Map<String, dynamic> body;
  UpdateCustomerRequest({required this.id, required this.body});
}

class DeleteCustomerRequest extends CustomerEvent {
  final String id;
  DeleteCustomerRequest({required this.id});
}
