part of 'outlet_action_bloc.dart';

abstract class OutletActionEvent {}

class CreateOutletActionRequest extends OutletActionEvent {
  final Map<String, dynamic> body;
  CreateOutletActionRequest({required this.body});
}

class UpdateOutletActionRequest extends OutletActionEvent {
  final String id;
  final Map<String, dynamic> body;
  UpdateOutletActionRequest({required this.id, required this.body});
}

class DeleteOutletActionRequest extends OutletActionEvent {
  final String id;
  DeleteOutletActionRequest({required this.id});
}
