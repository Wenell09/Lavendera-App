import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lavendera/core/error/api_exception.dart';
import 'package:lavendera/features/order/domain/entities/order_entity.dart';
import 'package:lavendera/features/order/domain/usecases/get_order_by_id_usecase.dart';
import 'package:lavendera/features/order/presentation/bloc/detail/order_detail_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockGetOrderByIdUsecase extends Mock implements GetOrderByIdUsecase {}

void main() {
  late OrderDetailBloc orderDetailBloc;
  late MockGetOrderByIdUsecase mockGetOrderByIdUsecase;

  setUp(() {
    mockGetOrderByIdUsecase = MockGetOrderByIdUsecase();
    orderDetailBloc = OrderDetailBloc(getOrderByIdUsecase: mockGetOrderByIdUsecase);
  });

  tearDown(() {
    orderDetailBloc.close();
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

  group('OrderDetailBloc', () {
    test('initial state is OrderDetailInitial', () {
      expect(orderDetailBloc.state, isA<OrderDetailInitial>());
    });

    blocTest<OrderDetailBloc, OrderDetailState>(
      'emits [OrderDetailLoading, OrderDetailLoaded] on GetOrderDetailRequest success',
      build: () {
        when(() => mockGetOrderByIdUsecase.call(any()))
            .thenAnswer((_) async => tOrder);
        return orderDetailBloc;
      },
      act: (bloc) => bloc.add(GetOrderDetailRequest(id: '1')),
      expect: () => [
        isA<OrderDetailLoading>(),
        isA<OrderDetailLoaded>(),
      ],
    );

    blocTest<OrderDetailBloc, OrderDetailState>(
      'emits [OrderDetailLoading, OrderDetailError] on GetOrderDetailRequest failure',
      build: () {
        when(() => mockGetOrderByIdUsecase.call(any()))
            .thenThrow(const ApiException(message: 'Order not found'));
        return orderDetailBloc;
      },
      act: (bloc) => bloc.add(GetOrderDetailRequest(id: '999')),
      expect: () => [
        isA<OrderDetailLoading>(),
        isA<OrderDetailError>(),
      ],
    );
  });
}
