import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lavendera/core/error/api_exception.dart';
import 'package:lavendera/features/order/domain/entities/order_entity.dart';
import 'package:lavendera/features/order/domain/usecases/cancel_order_usecase.dart';
import 'package:lavendera/features/order/domain/usecases/confirm_payment_usecase.dart';
import 'package:lavendera/features/order/domain/usecases/create_order_usecase.dart';
import 'package:lavendera/features/order/domain/usecases/input_cash_payment_usecase.dart';
import 'package:lavendera/features/order/domain/usecases/update_order_status_usecase.dart';
import 'package:lavendera/features/order/presentation/bloc/action/order_action_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockCreateOrderUsecase extends Mock implements CreateOrderUsecase {}
class MockUpdateOrderStatusUsecase extends Mock implements UpdateOrderStatusUsecase {}
class MockCancelOrderUsecase extends Mock implements CancelOrderUsecase {}
class MockConfirmPaymentUsecase extends Mock implements ConfirmPaymentUsecase {}
class MockInputCashPaymentUsecase extends Mock implements InputCashPaymentUsecase {}

void main() {
  late OrderActionBloc orderActionBloc;
  late MockCreateOrderUsecase mockCreateOrderUsecase;
  late MockUpdateOrderStatusUsecase mockUpdateOrderStatusUsecase;
  late MockCancelOrderUsecase mockCancelOrderUsecase;
  late MockConfirmPaymentUsecase mockConfirmPaymentUsecase;
  late MockInputCashPaymentUsecase mockInputCashPaymentUsecase;

  setUp(() {
    mockCreateOrderUsecase = MockCreateOrderUsecase();
    mockUpdateOrderStatusUsecase = MockUpdateOrderStatusUsecase();
    mockCancelOrderUsecase = MockCancelOrderUsecase();
    mockConfirmPaymentUsecase = MockConfirmPaymentUsecase();
    mockInputCashPaymentUsecase = MockInputCashPaymentUsecase();

    orderActionBloc = OrderActionBloc(
      createOrderUsecase: mockCreateOrderUsecase,
      updateOrderStatusUsecase: mockUpdateOrderStatusUsecase,
      cancelOrderUsecase: mockCancelOrderUsecase,
      confirmPaymentUsecase: mockConfirmPaymentUsecase,
      inputCashPaymentUsecase: mockInputCashPaymentUsecase,
    );
  });

  tearDown(() {
    orderActionBloc.close();
  });

  final tOrder = OrderEntity(
    id: '1',
    orderNumber: 'ORD-001',
    status: 'pending',
    paymentStatus: 'unpaid',
    subtotal: 10000,
    discountAmount: 0,
    totalAmount: 10000,
    paidAmount: 0,
    changeAmount: 0,
    outlet: OrderOutlet(id: 'o1', name: 'Outlet A'),
    customer: OrderCustomer(id: 'c1', name: 'Cust A'),
    items: [],
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  group('OrderActionBloc', () {
    blocTest<OrderActionBloc, OrderActionState>(
      'emits [OrderActionLoading, OrderActionSuccess] on CreateOrderActionRequest success',
      build: () {
        when(() => mockCreateOrderUsecase.call(any()))
            .thenAnswer((_) async => tOrder);
        return orderActionBloc;
      },
      act: (bloc) => bloc.add(CreateOrderActionRequest(body: {})),
      expect: () => [
        isA<OrderActionLoading>(),
        isA<OrderActionSuccess>(),
      ],
    );

    blocTest<OrderActionBloc, OrderActionState>(
      'emits [OrderActionLoading, OrderActionError] on CreateOrderActionRequest failure',
      build: () {
        when(() => mockCreateOrderUsecase.call(any()))
            .thenThrow(const ApiException(message: 'Error creating order'));
        return orderActionBloc;
      },
      act: (bloc) => bloc.add(CreateOrderActionRequest(body: {})),
      expect: () => [
        isA<OrderActionLoading>(),
        isA<OrderActionError>(),
      ],
    );

    blocTest<OrderActionBloc, OrderActionState>(
      'emits [OrderActionLoading, OrderActionSuccess] on UpdateOrderStatusActionRequest success',
      build: () {
        when(() => mockUpdateOrderStatusUsecase.call(any(), any()))
            .thenAnswer((_) async => tOrder);
        return orderActionBloc;
      },
      act: (bloc) => bloc.add(UpdateOrderStatusActionRequest(id: '1', status: 'completed')),
      expect: () => [
        isA<OrderActionLoading>(),
        isA<OrderActionSuccess>(),
      ],
    );
  });
}
