import 'package:bloc/bloc.dart';
import 'package:lavendera/core/error/api_exception.dart';
import 'package:lavendera/features/profile/domain/entities/profile.dart';
import 'package:lavendera/features/profile/domain/usecases/get_profile_usecase.dart';

part 'profile_detail_event.dart';
part 'profile_detail_state.dart';

class ProfileDetailBloc
    extends Bloc<ProfileDetailEvent, ProfileDetailState> {
  final GetProfileUsecase _getProfileUsecase;

  ProfileDetailBloc({required this._getProfileUsecase})
    : super(ProfileDetailInitial()) {
    on<GetProfileRequest>((event, emit) async {
      emit(ProfileDetailLoading());
      try {
        final profile = await _getProfileUsecase.call(event.id);
        emit(ProfileDetailLoaded(profile: profile));
      } on ApiException catch (e) {
        emit(ProfileDetailError(message: e.message));
      } catch (e) {
        emit(ProfileDetailError(message: 'Gagal memuat profil'));
      }
    });
  }
}
