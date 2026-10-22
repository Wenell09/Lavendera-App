import 'package:bloc/bloc.dart';
import 'package:lavendera/core/error/api_exception.dart';
import 'package:lavendera/features/user/domain/entities/user.dart';
import 'package:lavendera/features/user/domain/usecases/get_user_by_id_usecase.dart';

part 'user_detail_event.dart';
part 'user_detail_state.dart';

class UserDetailBloc
    extends Bloc<UserDetailEvent, UserDetailState> {
  final GetUserByIdUsecase _getUserByIdUsecase;

  UserDetailBloc({required this._getUserByIdUsecase})
    : super(UserDetailInitial()) {
    on<GetUserByIdRequest>((event, emit) async {
      emit(UserDetailLoading());
      try {
        final user = await _getUserByIdUsecase.call(event.id);
        emit(UserDetailLoaded(user: user));
      } on ApiException catch (e) {
        emit(UserDetailError(message: e.message));
      } catch (e) {
        emit(UserDetailError(message: 'Gagal memuat detail pengguna'));
      }
    });
  }
}
