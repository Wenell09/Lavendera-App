part of 'user_action_bloc.dart';

abstract class UserActionEvent {}

class CreateUserActionRequest extends UserActionEvent {
  final Map<String, dynamic> body;

  CreateUserActionRequest({required this.body});
}

class UpdateUserActionRequest extends UserActionEvent {
  final String id;
  final Map<String, dynamic> body;

  UpdateUserActionRequest({required this.id, required this.body});
}

class DeleteUserActionRequest extends UserActionEvent {
  final String id;

  DeleteUserActionRequest({required this.id});
}
