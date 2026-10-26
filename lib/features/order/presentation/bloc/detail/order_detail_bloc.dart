import 'package:bloc/bloc.dart';
import 'package:lavendera/core/error/api_exception.dart';
import '../../../domain/entities/order_entity.dart';
import '../../../domain/usecases/get_order_by_id_usecase.dart';

part 'order_detail_event.dart';
part 'order_detail_state.dart';

class OrderDetailBloc extends Bloc<OrderDetailEvent, OrderDetailState> {
  final GetOrderByIdUsecase getOrderByIdUsecase;

  OrderDetailBloc({required this.getOrderByIdUsecase})
      : super(OrderDetailInitial()) {
    on<GetOrderDetailRequest>(_onGetOrderDetail);
  }

  Future<void> _onGetOrderDetail(
    GetOrderDetailRequest event,
    Emitter<OrderDetailState> emit,
  ) async {
    emit(OrderDetailLoading());
    try {
      final order = await getOrderByIdUsecase.call(event.id);
      emit(OrderDetailLoaded(order: order));
    } on ApiException catch (e) {
      emit(OrderDetailError(message: e.message));
    } catch (e) {
      emit(OrderDetailError(message: 'Gagal memuat detail order'));
    }
  }
}
