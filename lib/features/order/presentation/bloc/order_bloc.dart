import 'package:bloc/bloc.dart';
import 'package:lavendera/core/error/api_exception.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/usecases/get_orders_usecase.dart';

part 'order_event.dart';
part 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final GetOrdersUsecase getOrdersUsecase;

  OrderBloc({required this.getOrdersUsecase})
      : super(OrderInitial()) {
    on<GetOrdersRequest>(_onGetOrders);
    on<RefreshOrdersRequest>(_onRefreshOrders);
  }

  Future<void> _onGetOrders(
    GetOrdersRequest event,
    Emitter<OrderState> emit,
  ) async {
    if (state is OrderPaginationLoading) {
      return;
    }

    final isFirstPage = event.page == 1;
    List<OrderEntity> currentOrders = [];

    if (state is OrderLoaded) {
      currentOrders = (state as OrderLoaded).orders;
    } else if (state is OrderError) {
      currentOrders = (state as OrderError).cachedOrders ?? [];
    }

    if (isFirstPage) {
      emit(OrderLoading());
    } else {
      emit(
        OrderPaginationLoading(
          orders: currentOrders,
          currentPage: (state is OrderLoaded)
              ? (state as OrderLoaded).currentPage
              : event.page - 1,
          hasMorePages: true,
        ),
      );
    }

    try {
      final result = await getOrdersUsecase.call(
        search: event.search,
        status: event.status,
        outletId: event.outletId,
        customerId: event.customerId,
        startDate: event.startDate,
        endDate: event.endDate,
        page: event.page,
        limit: event.limit,
      );

      final newOrders = result.data;
      final pagination = result.pagination;
      final bool hasMore;
      if (pagination != null) {
        hasMore = pagination.page < pagination.totalPages;
      } else {
        hasMore = newOrders.length >= event.limit;
      }

      List<OrderEntity> fullList;
      if (isFirstPage) {
        fullList = newOrders;
      } else {
        final existingIds = currentOrders.map((e) => e.id).toSet();
        final uniqueNewOrders =
            newOrders.where((e) => !existingIds.contains(e.id)).toList();
        fullList = [...currentOrders, ...uniqueNewOrders];
      }

      emit(
        OrderLoaded(
          orders: fullList,
          currentPage: event.page,
          hasMorePages: hasMore,
          activeStatus: event.status,
          searchQuery: event.search,
        ),
      );
    } on ApiException catch (e) {
      emit(
        OrderError(
          message: e.message,
          cachedOrders: currentOrders,
        ),
      );
    } catch (e) {
      emit(
        OrderError(
          message: 'Gagal memuat data order',
          cachedOrders: currentOrders,
        ),
      );
    }
  }

  Future<void> _onRefreshOrders(
    RefreshOrdersRequest event,
    Emitter<OrderState> emit,
  ) async {
    add(
      GetOrdersRequest(
        search: event.search,
        status: event.status,
        outletId: event.outletId,
        customerId: event.customerId,
        startDate: event.startDate,
        endDate: event.endDate,
        page: 1,
      ),
    );
  }
}
