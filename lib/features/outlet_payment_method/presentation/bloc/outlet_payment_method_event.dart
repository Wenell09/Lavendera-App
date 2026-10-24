part of 'outlet_payment_method_bloc.dart';

abstract class OutletPaymentMethodEvent {}

class GetOutletPaymentMethodsRequest extends OutletPaymentMethodEvent {
  final String outletId;
  final String? search;
  final int page;
  final int limit;

  GetOutletPaymentMethodsRequest({
    required this.outletId,
    this.search,
    this.page = 1,
    this.limit = 10,
  });
}
