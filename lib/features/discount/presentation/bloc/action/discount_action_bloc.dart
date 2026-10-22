import 'package:bloc/bloc.dart';
import 'package:lavendera/core/error/api_exception.dart';
import 'package:lavendera/features/discount/domain/usecases/create_discount_usecase.dart';
import 'package:lavendera/features/discount/domain/usecases/delete_discount_usecase.dart';
import 'package:lavendera/features/discount/domain/usecases/update_discount_usecase.dart';

part 'discount_action_event.dart';
part 'discount_action_state.dart';

class DiscountActionBloc
    extends Bloc<DiscountActionEvent, DiscountActionState> {
  final CreateDiscountUsecase _createDiscountUsecase;
  final UpdateDiscountUsecase _updateDiscountUsecase;
  final DeleteDiscountUsecase _deleteDiscountUsecase;

  DiscountActionBloc({
    required this._createDiscountUsecase,
    required this._updateDiscountUsecase,
    required this._deleteDiscountUsecase,
  })  : super(DiscountActionInitial()) {
    on<CreateDiscountActionRequest>((event, emit) async {
      emit(DiscountActionLoading());
      try {
        await _createDiscountUsecase.call(event.body);
        emit(DiscountActionSuccess(message: 'Berhasil menambah diskon'));
      } on ApiException catch (e) {
        emit(DiscountActionError(message: e.message));
      } catch (e) {
        emit(DiscountActionError(message: 'Gagal menambah diskon'));
      }
    });

    on<UpdateDiscountActionRequest>((event, emit) async {
      emit(DiscountActionLoading());
      try {
        await _updateDiscountUsecase.call(event.id, event.body);
        emit(DiscountActionSuccess(message: 'Berhasil memperbarui diskon'));
      } on ApiException catch (e) {
        emit(DiscountActionError(message: e.message));
      } catch (e) {
        emit(DiscountActionError(message: 'Gagal memperbarui diskon'));
      }
    });

    on<DeleteDiscountActionRequest>((event, emit) async {
      emit(DiscountActionLoading());
      try {
        await _deleteDiscountUsecase.call(event.id);
        emit(DiscountActionSuccess(message: 'Berhasil menghapus diskon'));
      } on ApiException catch (e) {
        emit(DiscountActionError(message: e.message));
      } catch (e) {
        emit(DiscountActionError(message: 'Gagal menghapus diskon'));
      }
    });
  }
}
