part of 'outlet_bloc.dart';

abstract class OutletState {}

final class OutletInitial extends OutletState {}

final class OutletLoading extends OutletState {}

final class OutletPaginationLoading extends OutletState {
  final List<Outlet> outlets;
  final int currentPage;
  final bool hasMorePages;
  OutletPaginationLoading({
    required this.outlets,
    required this.currentPage,
    required this.hasMorePages,
  });
}

final class OutletLoaded extends OutletState {
  final List<Outlet> outlets;
  final int currentPage;
  final bool hasMorePages;
  OutletLoaded({
    required this.outlets,
    required this.currentPage,
    required this.hasMorePages,
  });
}

final class OutletError extends OutletState {
  final String message;
  final List<Outlet>? cachedOutlets;
  OutletError({required this.message, this.cachedOutlets});
}
