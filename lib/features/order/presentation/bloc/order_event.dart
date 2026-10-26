part of 'order_bloc.dart';

abstract class OrderEvent {}

class GetOrdersRequest extends OrderEvent {
  final String? search;
  final String? status;
  final String? outletId;
  final String? customerId;
  final String? startDate;
  final String? endDate;
  final int page;
  final int limit;

  GetOrdersRequest({
    this.search,
    this.status,
    this.outletId,
    this.customerId,
    this.startDate,
    this.endDate,
    this.page = 1,
    this.limit = 10,
  });
}

class RefreshOrdersRequest extends OrderEvent {
  final String? search;
  final String? status;
  final String? outletId;
  final String? customerId;
  final String? startDate;
  final String? endDate;

  RefreshOrdersRequest({
    this.search,
    this.status,
    this.outletId,
    this.customerId,
    this.startDate,
    this.endDate,
  });
}
