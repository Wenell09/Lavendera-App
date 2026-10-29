part of 'profile_detail_bloc.dart';

abstract class ProfileDetailEvent {}

class GetProfileRequest extends ProfileDetailEvent {
  GetProfileRequest();
}
