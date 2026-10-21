part of 'outlet_bloc.dart';

class OutletEvent {}

class GetOutletsRequest extends OutletEvent {
  final String? search;
  final int page;
  final int limit;

  GetOutletsRequest({this.search, this.page = 1, this.limit = 10});
}

class CreateOutletRequest extends OutletEvent {
  final Map<String, dynamic> body;
  CreateOutletRequest({required this.body});
}

class UpdateOutletRequest extends OutletEvent {
  final String id;
  final Map<String, dynamic> body;
  UpdateOutletRequest({required this.id, required this.body});
}

class DeleteOutletRequest extends OutletEvent {
  final String id;
  DeleteOutletRequest({required this.id});
}
