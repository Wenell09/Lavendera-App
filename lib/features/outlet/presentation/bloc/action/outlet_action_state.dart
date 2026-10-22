part of 'outlet_action_bloc.dart';

abstract class OutletActionState {}

final class OutletActionInitial extends OutletActionState {}

final class OutletActionLoading extends OutletActionState {}

final class OutletActionSuccess extends OutletActionState {
  final String message;
  OutletActionSuccess({required this.message});
}

final class OutletActionError extends OutletActionState {
  final String message;
  OutletActionError({required this.message});
}
