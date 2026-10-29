part of 'user_outlet_bloc.dart';

class UserOutletState {}

final class UserOutletInitial extends UserOutletState {}

final class UserOutletLoading extends UserOutletState {}

final class UserOutletLoaded extends UserOutletState {
  final UserWithOutlet userOutlet;
  UserOutletLoaded({required this.userOutlet});
}

final class UserOutletError extends UserOutletState {
  final String message;
  UserOutletError({required this.message});
}
