import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lavendera/core/error/api_exception.dart';
import 'package:lavendera/core/models/pagination_model.dart';
import 'package:lavendera/features/customer/domain/entities/customer.dart';
import 'package:lavendera/features/customer/domain/usecases/get_customers_usecase.dart';
import 'package:lavendera/features/customer/presentation/bloc/customer_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockGetCustomersUsecase extends Mock implements GetCustomersUsecase {}

void main() {
  late CustomerBloc customerBloc;
  late MockGetCustomersUsecase mockGetCustomersUsecase;

  setUp(() {
    mockGetCustomersUsecase = MockGetCustomersUsecase();
    customerBloc = CustomerBloc(getCustomersUsecase: mockGetCustomersUsecase);
  });

  tearDown(() {
    customerBloc.close();
  });

  final tCustomer = Customer(
    id: '1',
    name: 'Customer 1',
    phone: '08123456789',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  group('CustomerBloc', () {
    test('initial state is CustomerInitial', () {
      expect(customerBloc.state, isA<CustomerInitial>());
    });

    blocTest<CustomerBloc, CustomerState>(
      'emits [CustomerLoading, CustomerLoaded] on GetCustomersRequest success',
      build: () {
        when(() => mockGetCustomersUsecase.call(
              search: any(named: 'search'),
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenAnswer(
          (_) async => PaginatedResult<Customer>(
            data: [tCustomer],
            pagination: Pagination(page: 1, limit: 10, total: 1, totalPages: 1),
          ),
        );
        return customerBloc;
      },
      act: (bloc) => bloc.add(GetCustomersRequest(page: 1)),
      expect: () => [
        isA<CustomerLoading>(),
        isA<CustomerLoaded>(),
      ],
    );

    blocTest<CustomerBloc, CustomerState>(
      'emits [CustomerLoading, CustomerError] on GetCustomersRequest failure',
      build: () {
        when(() => mockGetCustomersUsecase.call(
              search: any(named: 'search'),
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenThrow(const ApiException(message: 'Failed to fetch'));
        return customerBloc;
      },
      act: (bloc) => bloc.add(GetCustomersRequest(page: 1)),
      expect: () => [
        isA<CustomerLoading>(),
        isA<CustomerError>(),
      ],
    );
  });
}
