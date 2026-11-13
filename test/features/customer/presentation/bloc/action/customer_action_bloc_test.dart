import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lavendera/core/error/api_exception.dart';
import 'package:lavendera/features/customer/domain/entities/customer.dart';
import 'package:lavendera/features/customer/domain/usecases/create_customer_usecase.dart';
import 'package:lavendera/features/customer/domain/usecases/delete_customer_usecase.dart';
import 'package:lavendera/features/customer/domain/usecases/update_customer_usecase.dart';
import 'package:lavendera/features/customer/presentation/bloc/action/customer_action_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockCreateCustomerUsecase extends Mock implements CreateCustomerUsecase {}
class MockUpdateCustomerUsecase extends Mock implements UpdateCustomerUsecase {}
class MockDeleteCustomerUsecase extends Mock implements DeleteCustomerUsecase {}

void main() {
  late CustomerActionBloc customerActionBloc;
  late MockCreateCustomerUsecase mockCreateUsecase;
  late MockUpdateCustomerUsecase mockUpdateUsecase;
  late MockDeleteCustomerUsecase mockDeleteUsecase;

  setUp(() {
    mockCreateUsecase = MockCreateCustomerUsecase();
    mockUpdateUsecase = MockUpdateCustomerUsecase();
    mockDeleteUsecase = MockDeleteCustomerUsecase();

    customerActionBloc = CustomerActionBloc(
      createCustomerUsecase: mockCreateUsecase,
      updateCustomerUsecase: mockUpdateUsecase,
      deleteCustomerUsecase: mockDeleteUsecase,
    );
  });

  tearDown(() {
    customerActionBloc.close();
  });

  final tCustomer = Customer(
    id: '1',
    name: 'John Doe',
    phone: '123456789',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  group('CustomerActionBloc', () {
    blocTest<CustomerActionBloc, CustomerActionState>(
      'emits [Loading, Success] when CreateCustomerActionRequest is successful',
      build: () {
        when(() => mockCreateUsecase.call(any()))
            .thenAnswer((_) async => tCustomer);
        return customerActionBloc;
      },
      act: (bloc) => bloc.add(CreateCustomerActionRequest(body: {'name': 'John'})),
      expect: () => [
        isA<CustomerActionLoading>(),
        isA<CustomerActionSuccess>(),
      ],
    );

    blocTest<CustomerActionBloc, CustomerActionState>(
      'emits [Loading, Error] when CreateCustomerActionRequest fails',
      build: () {
        when(() => mockCreateUsecase.call(any()))
            .thenThrow(const ApiException(message: 'Failed'));
        return customerActionBloc;
      },
      act: (bloc) => bloc.add(CreateCustomerActionRequest(body: {'name': 'John'})),
      expect: () => [
        isA<CustomerActionLoading>(),
        isA<CustomerActionError>(),
      ],
    );
  });
}
