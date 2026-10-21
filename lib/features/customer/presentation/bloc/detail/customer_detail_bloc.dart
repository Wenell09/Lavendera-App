import 'package:bloc/bloc.dart';
import 'package:lavendera/core/error/api_exception.dart';
import 'package:lavendera/features/customer/domain/entities/customer.dart';
import 'package:lavendera/features/customer/domain/usecases/get_customer_by_id_usecase.dart';

part 'customer_detail_event.dart';
part 'customer_detail_state.dart';

class CustomerDetailBloc
    extends Bloc<CustomerDetailEvent, CustomerDetailState> {
  final GetCustomerByIdUsecase _getCustomerByIdUsecase;

  CustomerDetailBloc({required this._getCustomerByIdUsecase})
    : super(CustomerDetailInitial()) {
    on<GetCustomerByIdRequest>((event, emit) async {
      emit(CustomerDetailLoading());
      try {
        final customer = await _getCustomerByIdUsecase.call(event.id);
        emit(CustomerDetailLoaded(customer: customer));
      } on ApiException catch (e) {
        emit(CustomerDetailError(message: e.message));
      } catch (e) {
        emit(CustomerDetailError(message: 'Gagal memuat detail pelanggan'));
      }
    });
  }
}
