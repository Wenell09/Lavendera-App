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
