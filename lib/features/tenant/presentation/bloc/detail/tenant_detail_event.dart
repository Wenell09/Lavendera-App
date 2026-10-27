part of 'tenant_detail_bloc.dart';

abstract class TenantDetailEvent {}

class GetTenantRequest extends TenantDetailEvent {
  final String id;
  GetTenantRequest({required this.id});
}
