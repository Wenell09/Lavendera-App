part of 'outlet_bloc.dart';

abstract class OutletEvent {}

class GetOutletsRequest extends OutletEvent {
  final String? search;
  final int page;
  final int limit;

  GetOutletsRequest({this.search, this.page = 1, this.limit = 10});
}
