import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lavendera/core/error/api_exception.dart';
import 'package:lavendera/features/auth/domain/usecases/load_data_usecase.dart';
import 'package:lavendera/features/auth/domain/usecases/login_usecase.dart';
import 'package:lavendera/features/auth/domain/usecases/logout_usecase.dart';
import 'package:lavendera/features/auth/domain/usecases/register_usecase.dart';
import 'package:lavendera/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockLoginUsecase extends Mock implements LoginUsecase {}
class MockRegisterUsecase extends Mock implements RegisterUsecase {}
class MockLogoutUsecase extends Mock implements LogoutUsecase {}
class MockLoadDataUsecase extends Mock implements LoadDataUsecase {}

void main() {
  late AuthBloc authBloc;
  late MockLoginUsecase mockLoginUsecase;
  late MockRegisterUsecase mockRegisterUsecase;
  late MockLogoutUsecase mockLogoutUsecase;
  late MockLoadDataUsecase mockLoadDataUsecase;

  setUp(() {
    mockLoginUsecase = MockLoginUsecase();
    mockRegisterUsecase = MockRegisterUsecase();
    mockLogoutUsecase = MockLogoutUsecase();
    mockLoadDataUsecase = MockLoadDataUsecase();

    authBloc = AuthBloc(
      loginUsecase: mockLoginUsecase,
      registerUsecase: mockRegisterUsecase,
      loadDataUsecase: mockLoadDataUsecase,
      logoutUsecase: mockLogoutUsecase,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  test('initial state should be AuthInitial', () {
    expect(authBloc.state, isA<AuthInitial>());
  });

  group('LoginRequest', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthLoaded] when login is successful',
      build: () {
        when(() => mockLoginUsecase.call(any(), any()))
            .thenAnswer((_) async => {'id': '1', 'token': 'token123'});
        return authBloc;
      },
      act: (bloc) => bloc.add(LoginRequest(email: 'test@example.com', password: 'password')),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthLoaded>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when login fails with ApiException',
      build: () {
        when(() => mockLoginUsecase.call(any(), any()))
            .thenThrow(const ApiException(message: 'Invalid credentials'));
        return authBloc;
      },
      act: (bloc) => bloc.add(LoginRequest(email: 'test@example.com', password: 'wrong')),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>(),
      ],
    );
  });

  group('LogoutRequest', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Unauthenticated] when logout is successful',
      build: () {
        when(() => mockLogoutUsecase.call()).thenAnswer((_) async => {});
        return authBloc;
      },
      act: (bloc) => bloc.add(LogoutRequest()),
      expect: () => [
        isA<AuthLoading>(),
        isA<Unauthenticated>(),
      ],
    );
  });
}
