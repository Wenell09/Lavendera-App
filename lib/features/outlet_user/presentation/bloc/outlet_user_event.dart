part of 'outlet_user_bloc.dart';

abstract class OutletUserEvent {}

class GetOutletUsersRequest extends OutletUserEvent {
  final String outletId;
  final String? search;
  final int page;
  final int limit;

  GetOutletUsersRequest({
    required this.outletId,
    this.search,
    this.page = 1,
    this.limit = 10,
  });
}
