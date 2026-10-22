part of 'service_category_action_bloc.dart';

abstract class ServiceCategoryActionEvent {}

class CreateServiceCategoryActionRequest extends ServiceCategoryActionEvent {
  final Map<String, dynamic> body;
  CreateServiceCategoryActionRequest({required this.body});
}

class UpdateServiceCategoryActionRequest extends ServiceCategoryActionEvent {
  final String id;
  final Map<String, dynamic> body;
  UpdateServiceCategoryActionRequest({required this.id, required this.body});
}

class DeleteServiceCategoryActionRequest extends ServiceCategoryActionEvent {
  final String id;
  DeleteServiceCategoryActionRequest({required this.id});
}
