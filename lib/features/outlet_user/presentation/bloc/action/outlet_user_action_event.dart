part of 'outlet_user_action_bloc.dart';

abstract class OutletUserActionEvent {}

class AssignUserToOutletActionRequest extends OutletUserActionEvent {
  final String outletId;
  final String userId;

  AssignUserToOutletActionRequest({
    required this.outletId,
    required this.userId,
  });
}

class UnassignUserFromOutletActionRequest extends OutletUserActionEvent {
  final String outletId;
  final String userId;

  UnassignUserFromOutletActionRequest({
    required this.outletId,
    required this.userId,
  });
}
