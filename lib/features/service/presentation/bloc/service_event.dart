part of 'service_bloc.dart';

abstract class ServiceEvent {}

class GetServicesRequest extends ServiceEvent {
  final String? search;
  final String? categoryId;
  final int page;
  final int limit;

  GetServicesRequest({
    this.search,
    this.categoryId,
    this.page = 1,
    this.limit = 10,
  });
}

class CreateServiceRequest extends ServiceEvent {
  final Map<String, dynamic> body;
  CreateServiceRequest({required this.body});
}

class UpdateServiceRequest extends ServiceEvent {
  final String id;
  final Map<String, dynamic> body;
  UpdateServiceRequest({required this.id, required this.body});
}

class DeleteServiceRequest extends ServiceEvent {
  final String id;
  DeleteServiceRequest({required this.id});
}
