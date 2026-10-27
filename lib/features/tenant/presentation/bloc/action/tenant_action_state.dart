part of 'tenant_action_bloc.dart';

abstract class TenantActionState {}

class TenantActionInitial extends TenantActionState {}

class TenantActionLoading extends TenantActionState {}

class TenantActionSuccess extends TenantActionState {
  final String message;
  final Tenant? tenant;

  TenantActionSuccess({required this.message, this.tenant});
}

class TenantActionError extends TenantActionState {
  final String message;

  TenantActionError({required this.message});
}
