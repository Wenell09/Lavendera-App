part of 'user_action_bloc.dart';

abstract class UserActionState {}

final class UserActionInitial extends UserActionState {}

final class UserActionLoading extends UserActionState {}

final class UserActionSuccess extends UserActionState {
  final String message;

  UserActionSuccess({required this.message});
}

final class UserActionError extends UserActionState {
  final String message;

  UserActionError({required this.message});
}
