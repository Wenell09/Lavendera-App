import 'package:bloc/bloc.dart';
import 'package:lavendera/core/error/api_exception.dart';
import '../../../domain/entities/order_entity.dart';
import '../../../domain/usecases/cancel_order_usecase.dart';
import '../../../domain/usecases/confirm_payment_usecase.dart';
import '../../../domain/usecases/create_order_usecase.dart';
import '../../../domain/usecases/input_cash_payment_usecase.dart';
import '../../../domain/usecases/update_order_status_usecase.dart';

part 'order_action_event.dart';
part 'order_action_state.dart';

class OrderActionBloc extends Bloc<OrderActionEvent, OrderActionState> {
  final CreateOrderUsecase createOrderUsecase;
  final UpdateOrderStatusUsecase updateOrderStatusUsecase;
  final CancelOrderUsecase cancelOrderUsecase;
  final ConfirmPaymentUsecase confirmPaymentUsecase;
  final InputCashPaymentUsecase inputCashPaymentUsecase;

  OrderActionBloc({
    required this.createOrderUsecase,
    required this.updateOrderStatusUsecase,
    required this.cancelOrderUsecase,
    required this.confirmPaymentUsecase,
    required this.inputCashPaymentUsecase,
  }) : super(OrderActionInitial()) {
    on<CreateOrderActionRequest>(_onCreateOrder);
    on<UpdateOrderStatusActionRequest>(_onUpdateOrderStatus);
    on<CancelOrderActionRequest>(_onCancelOrder);
    on<ConfirmPaymentActionRequest>(_onConfirmPayment);
    on<InputCashPaymentActionRequest>(_onInputCashPayment);
  }

  Future<void> _onCreateOrder(
    CreateOrderActionRequest event,
    Emitter<OrderActionState> emit,
  ) async {
    emit(OrderActionLoading());
    try {
      final order = await createOrderUsecase.call(event.body);
      emit(
        OrderActionSuccess(
          message: 'Order berhasil dibuat',
          order: order,
        ),
      );
    } on ApiException catch (e) {
      emit(OrderActionError(message: e.message));
    } catch (e) {
      emit(OrderActionError(message: 'Gagal membuat order'));
    }
  }

  Future<void> _onUpdateOrderStatus(
    UpdateOrderStatusActionRequest event,
    Emitter<OrderActionState> emit,
  ) async {
    emit(OrderActionLoading());
    try {
      final order = await updateOrderStatusUsecase.call(event.id, event.status);
      emit(
        OrderActionSuccess(
          message: 'Status order berhasil diperbarui',
          order: order,
        ),
      );
    } on ApiException catch (e) {
      emit(OrderActionError(message: e.message));
    } catch (e) {
      emit(OrderActionError(message: 'Gagal memperbarui status order'));
    }
  }

  Future<void> _onCancelOrder(
    CancelOrderActionRequest event,
    Emitter<OrderActionState> emit,
  ) async {
    emit(OrderActionLoading());
    try {
      final order = await cancelOrderUsecase.call(event.id);
      emit(
        OrderActionSuccess(
          message: 'Order berhasil dibatalkan',
          order: order,
        ),
      );
    } on ApiException catch (e) {
      emit(OrderActionError(message: e.message));
    } catch (e) {
      emit(OrderActionError(message: 'Gagal membatalkan order'));
    }
  }

  Future<void> _onConfirmPayment(
    ConfirmPaymentActionRequest event,
    Emitter<OrderActionState> emit,
  ) async {
    emit(OrderActionLoading());
    try {
      final order = await confirmPaymentUsecase.call(
        event.orderId,
        event.paymentId,
      );
      emit(
        OrderActionSuccess(
          message: 'Pembayaran berhasil dikonfirmasi',
          order: order,
        ),
      );
    } on ApiException catch (e) {
      emit(OrderActionError(message: e.message));
    } catch (e) {
      emit(OrderActionError(message: 'Gagal mengonfirmasi pembayaran'));
    }
  }

  Future<void> _onInputCashPayment(
    InputCashPaymentActionRequest event,
    Emitter<OrderActionState> emit,
  ) async {
    emit(OrderActionLoading());
    try {
      final order = await inputCashPaymentUsecase.call(
        event.orderId,
        event.paidAmount,
      );
      emit(
        OrderActionSuccess(
          message: 'Pembayaran tunai berhasil dicatat',
          order: order,
        ),
      );
    } on ApiException catch (e) {
      emit(OrderActionError(message: e.message));
    } catch (e) {
      emit(OrderActionError(message: 'Gagal mencatat pembayaran tunai'));
    }
  }
}
