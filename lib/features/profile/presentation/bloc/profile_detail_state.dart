part of 'profile_detail_bloc.dart';

abstract class ProfileDetailState {}

class ProfileDetailInitial extends ProfileDetailState {}

class ProfileDetailLoading extends ProfileDetailState {}

class ProfileDetailLoaded extends ProfileDetailState {
  final Profile profile;
  ProfileDetailLoaded({required this.profile});
}

class ProfileDetailError extends ProfileDetailState {
  final String message;
  ProfileDetailError({required this.message});
}
