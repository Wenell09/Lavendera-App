part of 'discount_bloc.dart';

abstract class DiscountEvent {}

class GetDiscountsRequest extends DiscountEvent {
  final String? search;
  final int page;
  final int limit;

  GetDiscountsRequest({this.search, this.page = 1, this.limit = 10});
}
