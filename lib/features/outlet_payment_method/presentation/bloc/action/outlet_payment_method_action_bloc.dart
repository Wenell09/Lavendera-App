import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lavendera/core/error/api_exception.dart';
import 'package:lavendera/features/outlet_payment_method/domain/entities/outlet_payment_method.dart';
import 'package:lavendera/features/outlet_payment_method/domain/usecases/create_outlet_payment_method_usecase.dart';
import 'package:lavendera/features/outlet_payment_method/domain/usecases/delete_outlet_payment_method_usecase.dart';
import 'package:lavendera/features/outlet_payment_method/domain/usecases/update_outlet_payment_method_usecase.dart';

part 'outlet_payment_method_action_event.dart';
part 'outlet_payment_method_action_state.dart';

class OutletPaymentMethodActionBloc
    extends
        Bloc<OutletPaymentMethodActionEvent, OutletPaymentMethodActionState> {
  final CreateOutletPaymentMethodUsecase _createOutletPaymentMethodUsecase;
  final UpdateOutletPaymentMethodUsecase _updateOutletPaymentMethodUsecase;
  final DeleteOutletPaymentMethodUsecase _deleteOutletPaymentMethodUsecase;

  OutletPaymentMethodActionBloc({
    required this._createOutletPaymentMethodUsecase,
    required this._updateOutletPaymentMethodUsecase,
    required this._deleteOutletPaymentMethodUsecase,
  }) : super(OutletPaymentMethodActionInitial()) {
    on<CreateOutletPaymentMethodActionRequest>((event, emit) async {
      emit(OutletPaymentMethodActionLoading());
      try {
        final paymentMethod = await _createOutletPaymentMethodUsecase.call(
          event.outletId,
          event.body,
        );
        emit(
          OutletPaymentMethodActionSuccess(
            message: 'Metode pembayaran berhasil dibuat',
            paymentMethod: paymentMethod,
          ),
        );
      } on ApiException catch (e) {
        emit(OutletPaymentMethodActionError(message: e.message));
      } catch (e) {
        emit(OutletPaymentMethodActionError(message: 'Terjadi kesalahan'));
      }
    });

    on<UpdateOutletPaymentMethodActionRequest>((event, emit) async {
      emit(OutletPaymentMethodActionLoading());
      try {
        final paymentMethod = await _updateOutletPaymentMethodUsecase.call(
          event.outletId,
          event.paymentMethodId,
          event.body,
        );
        emit(
          OutletPaymentMethodActionSuccess(
            message: 'Metode pembayaran berhasil diperbarui',
            paymentMethod: paymentMethod,
          ),
        );
      } on ApiException catch (e) {
        emit(OutletPaymentMethodActionError(message: e.message));
      } catch (e) {
        emit(OutletPaymentMethodActionError(message: 'Terjadi kesalahan'));
      }
    });

    on<DeleteOutletPaymentMethodActionRequest>((event, emit) async {
      emit(OutletPaymentMethodActionLoading());
      try {
        await _deleteOutletPaymentMethodUsecase.call(
          event.outletId,
          event.paymentMethodId,
        );
        emit(
          OutletPaymentMethodActionSuccess(
            message: 'Metode pembayaran berhasil dihapus',
          ),
        );
      } on ApiException catch (e) {
        emit(OutletPaymentMethodActionError(message: e.message));
      } catch (e) {
        emit(OutletPaymentMethodActionError(message: 'Terjadi kesalahan'));
      }
    });
  }
}
