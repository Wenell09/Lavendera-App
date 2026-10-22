part of 'service_category_bloc.dart';

abstract class ServiceCategoryState {}

final class ServiceCategoryInitial extends ServiceCategoryState {}

final class ServiceCategoryLoading extends ServiceCategoryState {}

final class ServiceCategoryLoaded extends ServiceCategoryState {
  final List<ServiceCategory> categories;
  ServiceCategoryLoaded({required this.categories});
}

final class ServiceCategoryError extends ServiceCategoryState {
  final String message;
  final List<ServiceCategory>? cachedCategories;
  ServiceCategoryError({required this.message, this.cachedCategories});
}
