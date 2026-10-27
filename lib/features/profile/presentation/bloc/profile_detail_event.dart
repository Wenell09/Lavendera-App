part of 'profile_detail_bloc.dart';

abstract class ProfileDetailEvent {}

class GetProfileRequest extends ProfileDetailEvent {
  final String id;
  GetProfileRequest({required this.id});
}
