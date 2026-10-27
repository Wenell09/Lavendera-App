part of 'tenant_action_bloc.dart';

abstract class TenantActionEvent {}

class UpdateTenantActionRequest extends TenantActionEvent {
  final String id;
  final Map<String, dynamic> body;

  UpdateTenantActionRequest({required this.id, required this.body});
}
