import 'package:bloc/bloc.dart';
import 'package:lavendera/features/customer/domain/entities/customer.dart';
import 'package:lavendera/features/customer/domain/usecases/create_customer_usecase.dart';
import 'package:lavendera/features/customer/domain/usecases/delete_customer_usecase.dart';
import 'package:lavendera/features/customer/domain/usecases/get_customers_usecase.dart';
import 'package:lavendera/features/customer/domain/usecases/update_customer_usecase.dart';

part 'customer_event.dart';
part 'customer_state.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final GetCustomersUsecase _getCustomersUsecase;
  final CreateCustomerUsecase _createCustomerUsecase;
  final UpdateCustomerUsecase _updateCustomerUsecase;
  final DeleteCustomerUsecase _deleteCustomerUsecase;

  CustomerBloc({
    required this._getCustomersUsecase,
    required this._createCustomerUsecase,
    required this._updateCustomerUsecase,
    required this._deleteCustomerUsecase,
  }) : super(CustomerInitial()) {
    on<GetCustomersRequest>((event, emit) async {
      final isFirstPage = event.page == 1;
      List<Customer> currentCustomers = [];
      if (state is CustomerLoaded) {
        currentCustomers = (state as CustomerLoaded).customers;
      } else if (state is CustomerPaginationLoading) {
        currentCustomers = (state as CustomerPaginationLoading).customers;
      }

      if (isFirstPage) {
        emit(CustomerLoading());
      } else {
        emit(
          CustomerPaginationLoading(
            customers: currentCustomers,
            currentPage: event.page - 1,
            hasMorePages: true,
          ),
        );
      }

      try {
        final result = await _getCustomersUsecase.call(
          search: event.search,
          page: event.page,
          limit: event.limit,
        );

        final newCustomers = result.data;
        final pagination = result.pagination;
        final bool hasMore;
        if (pagination != null) {
          hasMore = pagination.page < pagination.totalPages;
        } else {
          hasMore = newCustomers.length >= event.limit;
        }

        final fullList = isFirstPage
            ? newCustomers
            : [...currentCustomers, ...newCustomers];
        emit(
          CustomerLoaded(
            customers: fullList,
            currentPage: event.page,
            hasMorePages: hasMore,
          ),
        );
      } catch (e) {
        emit(
          CustomerError(
            message: 'Gagal memuat data pelanggan',
            cachedCustomers: currentCustomers,
          ),
        );
      }
    });

    on<CreateCustomerRequest>((event, emit) async {
      emit(CustomerLoading());
      try {
        await _createCustomerUsecase.call(event.body);
        emit(CustomerActionSuccess(message: 'berhasil menambah pelanggan'));
      } catch (e) {
        emit(CustomerError(message: 'Gagal menambah pelanggan'));
      }
    });

    on<UpdateCustomerRequest>((event, emit) async {
      emit(CustomerLoading());
      try {
        await _updateCustomerUsecase.call(event.id, event.body);
        emit(CustomerActionSuccess(message: 'berhasil memperbarui pelanggan'));
      } catch (e) {
        emit(CustomerError(message: 'Gagal memperbarui pelanggan'));
      }
    });

    on<DeleteCustomerRequest>((event, emit) async {
      emit(CustomerLoading());
      try {
        await _deleteCustomerUsecase.call(event.id);
        emit(CustomerActionSuccess(message: 'berhasil menghapus pelanggan'));
      } catch (e) {
        emit(CustomerError(message: 'Gagal menghapus pelanggan'));
      }
    });
  }
}
