import 'package:bloc/bloc.dart';
import 'package:lavendera/core/error/api_exception.dart';
import 'package:lavendera/features/outlet_user/domain/entities/user_with_outlet.dart';
import 'package:lavendera/features/outlet_user/domain/usecases/get_user_outlet_usecase.dart';

part 'user_outlet_event.dart';
part 'user_outlet_state.dart';

class UserOutletBloc extends Bloc<UserOutletEvent, UserOutletState> {
  final GetUserOutletUsecase _getUserOutletUsecase;
  UserOutletBloc({required this._getUserOutletUsecase})
    : super(UserOutletInitial()) {
    on<GetUserOutletRequest>((event, emit) async {
      emit(UserOutletLoading());
      try {
        final userOutlet = await _getUserOutletUsecase.call(event.userId);
        emit(UserOutletLoaded(userOutlet: userOutlet));
      } on ApiException catch (e) {
        emit(
          UserOutletError(
            message: e.message.isNotEmpty
                ? e.message
                : 'Gagal memuat pengguna outlet',
          ),
        );
      } catch (e) {
        emit(UserOutletError(message: 'Gagal memuat pengguna outlet'));
      }
    });
  }
}
