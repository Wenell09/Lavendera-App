import 'package:bloc/bloc.dart';
import 'package:lavendera/core/error/api_exception.dart';
import 'package:lavendera/features/customer/domain/entities/customer.dart';
import 'package:lavendera/features/customer/domain/usecases/get_customers_usecase.dart';

part 'customer_event.dart';
part 'customer_state.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final GetCustomersUsecase _getCustomersUsecase;

  CustomerBloc({required this._getCustomersUsecase})
    : super(CustomerInitial()) {
    on<GetCustomersRequest>((event, emit) async {
      if (state is CustomerPaginationLoading || state is CustomerLoading) {
        return;
      }
      final isFirstPage = event.page == 1;
      List<Customer> currentCustomers = [];
      if (state is CustomerLoaded) {
        currentCustomers = (state as CustomerLoaded).customers;
      } else if (state is CustomerError) {
        currentCustomers = (state as CustomerError).cachedCustomers ?? [];
      }
      if (isFirstPage) {
        emit(CustomerLoading());
      } else {
        emit(
          CustomerPaginationLoading(
            customers: currentCustomers,
            currentPage: (state is CustomerLoaded)
                ? (state as CustomerLoaded).currentPage
                : event.page - 1,
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
        List<Customer> fullList;
        if (isFirstPage) {
          fullList = newCustomers;
        } else {
          final existingIds = currentCustomers.map((e) => e.id).toSet();
          final uniqueNewCustomers = newCustomers
              .where((e) => !existingIds.contains(e.id))
              .toList();
          fullList = [...currentCustomers, ...uniqueNewCustomers];
        }
        emit(
          CustomerLoaded(
            customers: fullList,
            currentPage: event.page,
            hasMorePages: hasMore,
          ),
        );
      } on ApiException {
        emit(
          CustomerError(
            message: 'Gagal memuat data pelanggan',
            cachedCustomers: currentCustomers,
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
  }
}
