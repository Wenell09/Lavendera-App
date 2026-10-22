part of 'service_category_action_bloc.dart';

abstract class ServiceCategoryActionState {}

final class ServiceCategoryActionInitial extends ServiceCategoryActionState {}

final class ServiceCategoryActionLoading extends ServiceCategoryActionState {}

final class ServiceCategoryActionSuccess extends ServiceCategoryActionState {
  final String message;
  ServiceCategoryActionSuccess({required this.message});
}

final class ServiceCategoryActionError extends ServiceCategoryActionState {
  final String message;
  ServiceCategoryActionError({required this.message});
}
