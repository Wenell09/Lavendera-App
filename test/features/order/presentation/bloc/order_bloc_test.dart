import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lavendera/core/error/api_exception.dart';
import 'package:lavendera/core/models/pagination_model.dart';
import 'package:lavendera/features/order/domain/entities/order_entity.dart';
import 'package:lavendera/features/order/domain/usecases/get_orders_usecase.dart';
import 'package:lavendera/features/order/presentation/bloc/order_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockGetOrdersUsecase extends Mock implements GetOrdersUsecase {}

void main() {
  late OrderBloc orderBloc;
  late MockGetOrdersUsecase mockGetOrdersUsecase;

  setUp(() {
    mockGetOrdersUsecase = MockGetOrdersUsecase();
    orderBloc = OrderBloc(getOrdersUsecase: mockGetOrdersUsecase);
  });

  tearDown(() {
    orderBloc.close();
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

  group('OrderBloc', () {
    blocTest<OrderBloc, OrderState>(
      'emits [OrderLoading, OrderLoaded] when GetOrdersRequest is successful',
      build: () {
        when(() => mockGetOrdersUsecase.call(
              search: any(named: 'search'),
              status: any(named: 'status'),
              outletId: any(named: 'outletId'),
              customerId: any(named: 'customerId'),
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async => PaginatedResult(data: [tOrder], pagination: null));
        return orderBloc;
      },
      act: (bloc) => bloc.add(GetOrdersRequest(page: 1)),
      expect: () => [
        isA<OrderLoading>(),
        isA<OrderLoaded>(),
      ],
    );

    blocTest<OrderBloc, OrderState>(
      'emits [OrderLoading, OrderError] when GetOrdersRequest fails',
      build: () {
        when(() => mockGetOrdersUsecase.call(
              search: any(named: 'search'),
              status: any(named: 'status'),
              outletId: any(named: 'outletId'),
              customerId: any(named: 'customerId'),
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenThrow(const ApiException(message: 'Error loading orders'));
        return orderBloc;
      },
      act: (bloc) => bloc.add(GetOrdersRequest(page: 1)),
      expect: () => [
        isA<OrderLoading>(),
        isA<OrderError>(),
      ],
    );
  });
}
