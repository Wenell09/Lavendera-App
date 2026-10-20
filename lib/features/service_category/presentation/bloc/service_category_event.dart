part of 'service_category_bloc.dart';

abstract class ServiceCategoryEvent {}

class GetServiceCategoriesRequest extends ServiceCategoryEvent {}

class CreateServiceCategoryRequest extends ServiceCategoryEvent {
  final Map<String, dynamic> body;
  CreateServiceCategoryRequest({required this.body});
}

class UpdateServiceCategoryRequest extends ServiceCategoryEvent {
  final String id;
  final Map<String, dynamic> body;
  UpdateServiceCategoryRequest({required this.id, required this.body});
}

class DeleteServiceCategoryRequest extends ServiceCategoryEvent {
  final String id;
  DeleteServiceCategoryRequest({required this.id});
}
