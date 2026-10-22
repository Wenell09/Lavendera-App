part of 'service_action_bloc.dart';

abstract class ServiceActionState {}

final class ServiceActionInitial extends ServiceActionState {}

final class ServiceActionLoading extends ServiceActionState {}

final class ServiceActionSuccess extends ServiceActionState {
  final String message;
  ServiceActionSuccess({required this.message});
}

final class ServiceActionError extends ServiceActionState {
  final String message;
  ServiceActionError({required this.message});
}
