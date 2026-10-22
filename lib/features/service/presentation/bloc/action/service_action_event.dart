part of 'service_action_bloc.dart';

abstract class ServiceActionEvent {}

class CreateServiceActionRequest extends ServiceActionEvent {
  final Map<String, dynamic> body;
  CreateServiceActionRequest({required this.body});
}

class UpdateServiceActionRequest extends ServiceActionEvent {
  final String id;
  final Map<String, dynamic> body;
  UpdateServiceActionRequest({required this.id, required this.body});
}

class DeleteServiceActionRequest extends ServiceActionEvent {
  final String id;
  DeleteServiceActionRequest({required this.id});
}
