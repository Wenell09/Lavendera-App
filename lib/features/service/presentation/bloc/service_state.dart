part of 'service_bloc.dart';

abstract class ServiceState {}

final class ServiceInitial extends ServiceState {}

final class ServiceLoading extends ServiceState {}

final class ServicePaginationLoading extends ServiceState {
  final List<LaundryService> services;
  final int currentPage;
  final bool hasMorePages;

  ServicePaginationLoading({
    required this.services,
    required this.currentPage,
    required this.hasMorePages,
  });
}

final class ServiceLoaded extends ServiceState {
  final List<LaundryService> services;
  final int currentPage;
  final bool hasMorePages;

  ServiceLoaded({
    required this.services,
    required this.currentPage,
    required this.hasMorePages,
  });
}

final class ServiceError extends ServiceState {
  final String message;
  final List<LaundryService>? cachedServices;

  ServiceError({required this.message, this.cachedServices});
}
