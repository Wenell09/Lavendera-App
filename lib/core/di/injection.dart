import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:lavendera/core/network/auth_interceptor.dart';
import 'package:lavendera/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:lavendera/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:lavendera/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:lavendera/features/auth/domain/usecases/load_data_usecase.dart';
import 'package:lavendera/features/auth/domain/usecases/login_usecase.dart';
import 'package:lavendera/features/auth/domain/usecases/logout_usecase.dart';
import 'package:lavendera/features/auth/domain/usecases/register_usecase.dart';
import 'package:lavendera/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:lavendera/features/customer/data/datasources/customer_remote_data_source.dart';
import 'package:lavendera/features/customer/data/repositories/customer_repository_impl.dart';
import 'package:lavendera/features/customer/domain/usecases/create_customer_usecase.dart';
import 'package:lavendera/features/customer/domain/usecases/delete_customer_usecase.dart';
import 'package:lavendera/features/customer/domain/usecases/get_customer_by_id_usecase.dart';
import 'package:lavendera/features/customer/domain/usecases/get_customers_usecase.dart';
import 'package:lavendera/features/customer/domain/usecases/update_customer_usecase.dart';
import 'package:lavendera/features/customer/presentation/bloc/customer_bloc.dart';
import 'package:lavendera/features/customer/presentation/bloc/detail/customer_detail_bloc.dart';
import 'package:lavendera/features/discount/data/datasources/discount_remote_data_source.dart';
import 'package:lavendera/features/discount/data/repositories/discount_repository_impl.dart';
import 'package:lavendera/features/discount/domain/usecases/create_discount_usecase.dart';
import 'package:lavendera/features/discount/domain/usecases/delete_discount_usecase.dart';
import 'package:lavendera/features/discount/domain/usecases/get_discount_by_id_usecase.dart';
import 'package:lavendera/features/discount/domain/usecases/get_discounts_usecase.dart';
import 'package:lavendera/features/discount/domain/usecases/update_discount_usecase.dart';
import 'package:lavendera/features/discount/presentation/bloc/discount_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );
  // Auth
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSource());
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSource(secureStorage: sl<FlutterSecureStorage>()),
  );
  sl.registerLazySingleton<AuthRepositoryImpl>(
    () => AuthRepositoryImpl(
      authRemoteDataSource: sl<AuthRemoteDataSource>(),
      authLocalDataSource: sl<AuthLocalDataSource>(),
    ),
  );
  sl.registerLazySingleton(() => LoginUsecase(sl<AuthRepositoryImpl>()));
  sl.registerLazySingleton(() => RegisterUsecase(sl<AuthRepositoryImpl>()));
  sl.registerLazySingleton(() => LoadDataUsecase(sl<AuthRepositoryImpl>()));
  sl.registerLazySingleton(() => LogoutUsecase(sl<AuthRepositoryImpl>()));
  sl.registerFactory(
    () => AuthBloc(
      loginUsecase: sl<LoginUsecase>(),
      registerUsecase: sl<RegisterUsecase>(),
      loadDataUsecase: sl<LoadDataUsecase>(),
      logoutUsecase: sl<LogoutUsecase>(),
    ),
  );
  // Customer
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio();
    dio.interceptors.add(
      AuthInterceptor(secureStorage: sl<FlutterSecureStorage>()),
    );
    return dio;
  });
  sl.registerLazySingleton<CustomerRemoteDataSource>(
    () => CustomerRemoteDataSource(dio: sl<Dio>()),
  );
  sl.registerLazySingleton<CustomerRepositoryImpl>(
    () => CustomerRepositoryImpl(
      remoteDataSource: sl<CustomerRemoteDataSource>(),
    ),
  );
  sl.registerLazySingleton(
    () => GetCustomersUsecase(sl<CustomerRepositoryImpl>()),
  );
  sl.registerLazySingleton(
    () => CreateCustomerUsecase(sl<CustomerRepositoryImpl>()),
  );
  sl.registerLazySingleton(
    () => GetCustomerByIdUsecase(sl<CustomerRepositoryImpl>()),
  );
  sl.registerLazySingleton(
    () => UpdateCustomerUsecase(sl<CustomerRepositoryImpl>()),
  );
  sl.registerLazySingleton(
    () => DeleteCustomerUsecase(sl<CustomerRepositoryImpl>()),
  );
  sl.registerFactory(
    () => CustomerBloc(
      getCustomersUsecase: sl<GetCustomersUsecase>(),
      createCustomerUsecase: sl<CreateCustomerUsecase>(),
      updateCustomerUsecase: sl<UpdateCustomerUsecase>(),
      deleteCustomerUsecase: sl<DeleteCustomerUsecase>(),
    ),
  );
  sl.registerFactory(
    () => CustomerDetailBloc(
      getCustomerByIdUsecase: sl<GetCustomerByIdUsecase>(),
    ),
  );
  // Discount
  sl.registerLazySingleton<DiscountRemoteDataSource>(
    () => DiscountRemoteDataSource(dio: sl<Dio>()),
  );
  sl.registerLazySingleton<DiscountRepositoryImpl>(
    () => DiscountRepositoryImpl(
      remoteDataSource: sl<DiscountRemoteDataSource>(),
    ),
  );
  sl.registerLazySingleton(
    () => GetDiscountsUsecase(sl<DiscountRepositoryImpl>()),
  );
  sl.registerLazySingleton(
    () => CreateDiscountUsecase(sl<DiscountRepositoryImpl>()),
  );
  sl.registerLazySingleton(
    () => GetDiscountByIdUsecase(sl<DiscountRepositoryImpl>()),
  );
  sl.registerLazySingleton(
    () => UpdateDiscountUsecase(sl<DiscountRepositoryImpl>()),
  );
  sl.registerLazySingleton(
    () => DeleteDiscountUsecase(sl<DiscountRepositoryImpl>()),
  );
  sl.registerFactory(
    () => DiscountBloc(
      getDiscountsUsecase: sl<GetDiscountsUsecase>(),
      createDiscountUsecase: sl<CreateDiscountUsecase>(),
      updateDiscountUsecase: sl<UpdateDiscountUsecase>(),
      deleteDiscountUsecase: sl<DeleteDiscountUsecase>(),
    ),
  );
}
