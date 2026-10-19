part of 'customer_detail_bloc.dart';

abstract class CustomerDetailEvent {}

class GetCustomerByIdRequest extends CustomerDetailEvent {
  final String id;
  GetCustomerByIdRequest({required this.id});
}
