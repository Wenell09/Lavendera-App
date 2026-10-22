part of 'customer_bloc.dart';

abstract class CustomerEvent {}

class GetCustomersRequest extends CustomerEvent {
  final String? search;
  final int page;
  final int limit;

  GetCustomersRequest({this.search, this.page = 1, this.limit = 10});
}
