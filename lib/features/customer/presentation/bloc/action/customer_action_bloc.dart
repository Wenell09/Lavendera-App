import 'package:bloc/bloc.dart';
import 'package:lavendera/core/error/api_exception.dart';
import 'package:lavendera/features/customer/domain/usecases/create_customer_usecase.dart';
import 'package:lavendera/features/customer/domain/usecases/delete_customer_usecase.dart';
import 'package:lavendera/features/customer/domain/usecases/update_customer_usecase.dart';

part 'customer_action_event.dart';
part 'customer_action_state.dart';

class CustomerActionBloc
    extends Bloc<CustomerActionEvent, CustomerActionState> {
  final CreateCustomerUsecase _createCustomerUsecase;
  final UpdateCustomerUsecase _updateCustomerUsecase;
  final DeleteCustomerUsecase _deleteCustomerUsecase;

  CustomerActionBloc({
    required this._createCustomerUsecase,
    required this._updateCustomerUsecase,
    required this._deleteCustomerUsecase,
  }) : super(CustomerActionInitial()) {
    on<CreateCustomerActionRequest>((event, emit) async {
      emit(CustomerActionLoading());
      try {
        await _createCustomerUsecase.call(event.body);
        emit(CustomerActionSuccess(message: 'berhasil menambah pelanggan'));
      } on ApiException catch (e) {
        emit(CustomerActionError(message: e.message));
      } catch (e) {
        emit(CustomerActionError(message: 'Gagal menambah pelanggan'));
      }
    });

    on<UpdateCustomerActionRequest>((event, emit) async {
      emit(CustomerActionLoading());
      try {
        await _updateCustomerUsecase.call(event.id, event.body);
        emit(CustomerActionSuccess(message: 'berhasil memperbarui pelanggan'));
      } on ApiException catch (e) {
        emit(CustomerActionError(message: e.message));
      } catch (e) {
        emit(CustomerActionError(message: 'Gagal memperbarui pelanggan'));
      }
    });

    on<DeleteCustomerActionRequest>((event, emit) async {
      emit(CustomerActionLoading());
      try {
        await _deleteCustomerUsecase.call(event.id);
        emit(CustomerActionSuccess(message: 'berhasil menghapus pelanggan'));
      } on ApiException catch (e) {
        emit(CustomerActionError(message: e.message));
      } catch (e) {
        emit(CustomerActionError(message: 'Gagal menghapus pelanggan'));
      }
    });
  }
}
