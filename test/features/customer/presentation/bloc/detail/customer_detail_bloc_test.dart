import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lavendera/core/error/api_exception.dart';
import 'package:lavendera/features/customer/domain/entities/customer.dart';
import 'package:lavendera/features/customer/domain/usecases/get_customer_by_id_usecase.dart';
import 'package:lavendera/features/customer/presentation/bloc/detail/customer_detail_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockGetCustomerByIdUsecase extends Mock implements GetCustomerByIdUsecase {}

void main() {
  late CustomerDetailBloc customerDetailBloc;
  late MockGetCustomerByIdUsecase mockGetCustomerByIdUsecase;

  setUp(() {
    mockGetCustomerByIdUsecase = MockGetCustomerByIdUsecase();
    customerDetailBloc = CustomerDetailBloc(
      getCustomerByIdUsecase: mockGetCustomerByIdUsecase,
    );
  });

  tearDown(() {
    customerDetailBloc.close();
  });

  final tCustomer = Customer(
    id: '1',
    name: 'Customer 1',
    phone: '08123456789',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  group('CustomerDetailBloc', () {
    test('initial state is CustomerDetailInitial', () {
      expect(customerDetailBloc.state, isA<CustomerDetailInitial>());
    });

    blocTest<CustomerDetailBloc, CustomerDetailState>(
      'emits [CustomerDetailLoading, CustomerDetailLoaded] on GetCustomerByIdRequest success',
      build: () {
        when(() => mockGetCustomerByIdUsecase.call(any()))
            .thenAnswer((_) async => tCustomer);
        return customerDetailBloc;
      },
      act: (bloc) => bloc.add(GetCustomerByIdRequest(id: '1')),
      expect: () => [
        isA<CustomerDetailLoading>(),
        isA<CustomerDetailLoaded>(),
      ],
    );

    blocTest<CustomerDetailBloc, CustomerDetailState>(
      'emits [CustomerDetailLoading, CustomerDetailError] on GetCustomerByIdRequest failure',
      build: () {
        when(() => mockGetCustomerByIdUsecase.call(any()))
            .thenThrow(const ApiException(message: 'Customer not found'));
        return customerDetailBloc;
      },
      act: (bloc) => bloc.add(GetCustomerByIdRequest(id: '999')),
      expect: () => [
        isA<CustomerDetailLoading>(),
        isA<CustomerDetailError>(),
      ],
    );
  });
}
