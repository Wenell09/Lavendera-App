part of 'tenant_detail_bloc.dart';

abstract class TenantDetailState {}

class TenantDetailInitial extends TenantDetailState {}

class TenantDetailLoading extends TenantDetailState {}

class TenantDetailLoaded extends TenantDetailState {
  final Tenant tenant;
  TenantDetailLoaded({required this.tenant});
}

class TenantDetailError extends TenantDetailState {
  final String message;
  TenantDetailError({required this.message});
}
