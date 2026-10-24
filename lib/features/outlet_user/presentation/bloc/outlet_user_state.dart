part of 'outlet_user_bloc.dart';

abstract class OutletUserState {}

class OutletUserInitial extends OutletUserState {}

class OutletUserLoading extends OutletUserState {}

class OutletUserLoaded extends OutletUserState {
  final List<UserSummary> users;
  final OutletSummary? outlet;
  final int currentPage;
  final bool hasMorePages;

  OutletUserLoaded({
    required this.users,
    this.outlet,
    this.currentPage = 1,
    this.hasMorePages = false,
  });
}

class OutletUserError extends OutletUserState {
  final String message;
  final List<UserSummary>? cachedUsers;

  OutletUserError({
    required this.message,
    this.cachedUsers,
  });
}
