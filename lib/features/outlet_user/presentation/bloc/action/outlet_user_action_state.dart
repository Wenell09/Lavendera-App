part of 'outlet_user_action_bloc.dart';

abstract class OutletUserActionState {}

class OutletUserActionInitial extends OutletUserActionState {}

class OutletUserActionLoading extends OutletUserActionState {}

class OutletUserActionSuccess extends OutletUserActionState {
  final String message;

  OutletUserActionSuccess({required this.message});
}

class OutletUserActionError extends OutletUserActionState {
  final String message;

  OutletUserActionError({required this.message});
}
