part of 'discount_bloc.dart';

class DiscountEvent {}

class GetDiscountsRequest extends DiscountEvent {
  final String? search;
  final int page;
  final int limit;

  GetDiscountsRequest({this.search, this.page = 1, this.limit = 10});
}

class CreateDiscountRequest extends DiscountEvent {
  final Map<String, dynamic> body;
  CreateDiscountRequest({required this.body});
}

class UpdateDiscountRequest extends DiscountEvent {
  final String id;
  final Map<String, dynamic> body;
  UpdateDiscountRequest({required this.id, required this.body});
}

class DeleteDiscountRequest extends DiscountEvent {
  final String id;
  DeleteDiscountRequest({required this.id});
}
