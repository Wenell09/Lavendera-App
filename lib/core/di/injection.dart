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
import 'package:lavendera/features/customer/presentation/bloc/action/customer_action_bloc.dart';
import 'package:lavendera/features/customer/presentation/bloc/customer_bloc.dart';
import 'package:lavendera/features/customer/presentation/bloc/detail/customer_detail_bloc.dart';
import 'package:lavendera/features/discount/data/datasources/discount_remote_data_source.dart';
import 'package:lavendera/features/discount/data/repositories/discount_repository_impl.dart';
import 'package:lavendera/features/discount/domain/usecases/create_discount_usecase.dart';
import 'package:lavendera/features/discount/domain/usecases/delete_discount_usecase.dart';
import 'package:lavendera/features/discount/domain/usecases/get_discount_by_id_usecase.dart';
import 'package:lavendera/features/discount/domain/usecases/get_discounts_usecase.dart';
import 'package:lavendera/features/discount/domain/usecases/update_discount_usecase.dart';
import 'package:lavendera/features/discount/presentation/bloc/action/discount_action_bloc.dart';
import 'package:lavendera/features/discount/presentation/bloc/discount_bloc.dart';
import 'package:lavendera/features/outlet/data/datasources/outlet_remote_data_source.dart';
import 'package:lavendera/features/outlet/data/repositories/outlet_repository_impl.dart';
import 'package:lavendera/features/outlet/domain/usecases/create_outlet_usecase.dart';
import 'package:lavendera/features/outlet/domain/usecases/delete_outlet_usecase.dart';
import 'package:lavendera/features/outlet/domain/usecases/get_outlet_by_id_usecase.dart';
import 'package:lavendera/features/outlet/domain/usecases/get_outlets_usecase.dart';
import 'package:lavendera/features/outlet/domain/usecases/update_outlet_usecase.dart';
import 'package:lavendera/features/outlet/presentation/bloc/action/outlet_action_bloc.dart';
import 'package:lavendera/features/outlet/presentation/bloc/outlet_bloc.dart';
import 'package:lavendera/features/service/data/datasources/service_remote_data_source.dart';
import 'package:lavendera/features/service/data/repositories/service_repository_impl.dart';
import 'package:lavendera/features/service/domain/usecases/create_service_usecase.dart';
import 'package:lavendera/features/service/domain/usecases/delete_service_usecase.dart';
import 'package:lavendera/features/service/domain/usecases/get_service_by_id_usecase.dart';
import 'package:lavendera/features/service/domain/usecases/get_services_usecase.dart';
import 'package:lavendera/features/service/domain/usecases/update_service_usecase.dart';
import 'package:lavendera/features/service/presentation/bloc/action/service_action_bloc.dart';
import 'package:lavendera/features/service/presentation/bloc/service_bloc.dart';
import 'package:lavendera/features/service_category/data/datasources/service_category_remote_data_source.dart';
import 'package:lavendera/features/service_category/data/repositories/service_category_repository_impl.dart';
import 'package:lavendera/features/service_category/domain/usecases/create_service_category_usecase.dart';
import 'package:lavendera/features/service_category/domain/usecases/delete_service_category_usecase.dart';
import 'package:lavendera/features/service_category/domain/usecases/get_service_categories_usecase.dart';
import 'package:lavendera/features/service_category/domain/usecases/get_service_category_by_id_usecase.dart';
import 'package:lavendera/features/service_category/domain/usecases/update_service_category_usecase.dart';
import 'package:lavendera/features/service_category/presentation/bloc/action/service_category_action_bloc.dart';
import 'package:lavendera/features/service_category/presentation/bloc/service_category_bloc.dart';
import 'package:lavendera/features/outlet_user/data/datasources/outlet_user_remote_data_source.dart';
import 'package:lavendera/features/outlet_user/data/repositories/outlet_user_repository_impl.dart';
import 'package:lavendera/features/outlet_user/domain/usecases/assign_user_to_outlet_usecase.dart';
import 'package:lavendera/features/outlet_user/domain/usecases/get_outlet_users_usecase.dart';
import 'package:lavendera/features/outlet_user/domain/usecases/get_user_outlets_usecase.dart';
import 'package:lavendera/features/outlet_user/domain/usecases/unassign_user_from_outlet_usecase.dart';
import 'package:lavendera/features/outlet_user/presentation/bloc/action/outlet_user_action_bloc.dart';
import 'package:lavendera/features/outlet_user/presentation/bloc/outlet_user_bloc.dart';
import 'package:lavendera/features/user/data/datasources/user_remote_data_source.dart';
import 'package:lavendera/features/user/data/repositories/user_repository_impl.dart';
import 'package:lavendera/features/user/domain/usecases/create_user_usecase.dart';
import 'package:lavendera/features/user/domain/usecases/delete_user_usecase.dart';
import 'package:lavendera/features/user/domain/usecases/get_user_by_id_usecase.dart';
import 'package:lavendera/features/user/domain/usecases/get_users_usecase.dart';
import 'package:lavendera/features/user/domain/usecases/update_user_usecase.dart';
import 'package:lavendera/features/user/presentation/bloc/action/user_action_bloc.dart';
import 'package:lavendera/features/user/presentation/bloc/detail/user_detail_bloc.dart';
import 'package:lavendera/features/user/presentation/bloc/user_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio();
    dio.interceptors.add(
      AuthInterceptor(secureStorage: sl<FlutterSecureStorage>()),
    );
    return dio;
  });
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
    ),
  );
  sl.registerFactory(
    () => CustomerActionBloc(
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
    ),
  );
  sl.registerFactory(
    () => DiscountActionBloc(
      createDiscountUsecase: sl<CreateDiscountUsecase>(),
      updateDiscountUsecase: sl<UpdateDiscountUsecase>(),
      deleteDiscountUsecase: sl<DeleteDiscountUsecase>(),
    ),
  );
  // Service Category
  sl.registerLazySingleton<ServiceCategoryRemoteDataSource>(
    () => ServiceCategoryRemoteDataSource(dio: sl<Dio>()),
  );
  sl.registerLazySingleton<ServiceCategoryRepositoryImpl>(
    () => ServiceCategoryRepositoryImpl(
      remoteDataSource: sl<ServiceCategoryRemoteDataSource>(),
    ),
  );
  sl.registerLazySingleton(
    () => GetServiceCategoriesUsecase(sl<ServiceCategoryRepositoryImpl>()),
  );
  sl.registerLazySingleton(
    () => GetServiceCategoryByIdUsecase(sl<ServiceCategoryRepositoryImpl>()),
  );
  sl.registerLazySingleton(
    () => CreateServiceCategoryUsecase(sl<ServiceCategoryRepositoryImpl>()),
  );
  sl.registerLazySingleton(
    () => UpdateServiceCategoryUsecase(sl<ServiceCategoryRepositoryImpl>()),
  );
  sl.registerLazySingleton(
    () => DeleteServiceCategoryUsecase(sl<ServiceCategoryRepositoryImpl>()),
  );
  sl.registerFactory(
    () => ServiceCategoryBloc(
      getServiceCategoriesUsecase: sl<GetServiceCategoriesUsecase>(),
    ),
  );
  sl.registerFactory(
    () => ServiceCategoryActionBloc(
      createServiceCategoryUsecase: sl<CreateServiceCategoryUsecase>(),
      updateServiceCategoryUsecase: sl<UpdateServiceCategoryUsecase>(),
      deleteServiceCategoryUsecase: sl<DeleteServiceCategoryUsecase>(),
    ),
  );
  // Service
  sl.registerLazySingleton<ServiceRemoteDataSource>(
    () => ServiceRemoteDataSource(dio: sl<Dio>()),
  );
  sl.registerLazySingleton<ServiceRepositoryImpl>(
    () =>
        ServiceRepositoryImpl(remoteDataSource: sl<ServiceRemoteDataSource>()),
  );
  sl.registerLazySingleton(
    () => GetServicesUsecase(sl<ServiceRepositoryImpl>()),
  );
  sl.registerLazySingleton(
    () => GetServiceByIdUsecase(sl<ServiceRepositoryImpl>()),
  );
  sl.registerLazySingleton(
    () => CreateServiceUsecase(sl<ServiceRepositoryImpl>()),
  );
  sl.registerLazySingleton(
    () => UpdateServiceUsecase(sl<ServiceRepositoryImpl>()),
  );
  sl.registerLazySingleton(
    () => DeleteServiceUsecase(sl<ServiceRepositoryImpl>()),
  );
  sl.registerFactory(
    () => ServiceBloc(
      getServicesUsecase: sl<GetServicesUsecase>(),
    ),
  );
  sl.registerFactory(
    () => ServiceActionBloc(
      createServiceUsecase: sl<CreateServiceUsecase>(),
      updateServiceUsecase: sl<UpdateServiceUsecase>(),
      deleteServiceUsecase: sl<DeleteServiceUsecase>(),
    ),
  );
  // Outlet
  sl.registerLazySingleton<OutletRemoteDataSource>(
    () => OutletRemoteDataSource(dio: sl<Dio>()),
  );
  sl.registerLazySingleton<OutletRepositoryImpl>(
    () => OutletRepositoryImpl(remoteDataSource: sl<OutletRemoteDataSource>()),
  );
  sl.registerLazySingleton(() => GetOutletsUsecase(sl<OutletRepositoryImpl>()));
  sl.registerLazySingleton(
    () => CreateOutletUsecase(sl<OutletRepositoryImpl>()),
  );
  sl.registerLazySingleton(
    () => GetOutletByIdUsecase(sl<OutletRepositoryImpl>()),
  );
  sl.registerLazySingleton(
    () => UpdateOutletUsecase(sl<OutletRepositoryImpl>()),
  );
  sl.registerLazySingleton(
    () => DeleteOutletUsecase(sl<OutletRepositoryImpl>()),
  );
  sl.registerFactory(
    () => OutletBloc(
      getOutletsUsecase: sl<GetOutletsUsecase>(),
    ),
  );
  sl.registerFactory(
    () => OutletActionBloc(
      createOutletUsecase: sl<CreateOutletUsecase>(),
      updateOutletUsecase: sl<UpdateOutletUsecase>(),
      deleteOutletUsecase: sl<DeleteOutletUsecase>(),
    ),
  );
  // User
  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSource(dio: sl<Dio>()),
  );
  sl.registerLazySingleton<UserRepositoryImpl>(
    () => UserRepositoryImpl(remoteDataSource: sl<UserRemoteDataSource>()),
  );
  sl.registerLazySingleton(() => GetUsersUsecase(sl<UserRepositoryImpl>()));
  sl.registerLazySingleton(() => CreateUserUsecase(sl<UserRepositoryImpl>()));
  sl.registerLazySingleton(() => GetUserByIdUsecase(sl<UserRepositoryImpl>()));
  sl.registerLazySingleton(() => UpdateUserUsecase(sl<UserRepositoryImpl>()));
  sl.registerLazySingleton(() => DeleteUserUsecase(sl<UserRepositoryImpl>()));
  sl.registerFactory(
    () => UserBloc(getUsersUsecase: sl<GetUsersUsecase>()),
  );
  sl.registerFactory(
    () => UserActionBloc(
      createUserUsecase: sl<CreateUserUsecase>(),
      updateUserUsecase: sl<UpdateUserUsecase>(),
      deleteUserUsecase: sl<DeleteUserUsecase>(),
    ),
  );
  sl.registerFactory(
    () => UserDetailBloc(getUserByIdUsecase: sl<GetUserByIdUsecase>()),
  );
  // Outlet User
  sl.registerLazySingleton<OutletUserRemoteDataSource>(
    () => OutletUserRemoteDataSource(dio: sl<Dio>()),
  );
  sl.registerLazySingleton<OutletUserRepositoryImpl>(
    () => OutletUserRepositoryImpl(remoteDataSource: sl<OutletUserRemoteDataSource>()),
  );
  sl.registerLazySingleton(() => GetOutletUsersUsecase(sl<OutletUserRepositoryImpl>()));
  sl.registerLazySingleton(() => AssignUserToOutletUsecase(sl<OutletUserRepositoryImpl>()));
  sl.registerLazySingleton(() => UnassignUserFromOutletUsecase(sl<OutletUserRepositoryImpl>()));
  sl.registerLazySingleton(() => GetUserOutletsUsecase(sl<OutletUserRepositoryImpl>()));
  sl.registerFactory(
    () => OutletUserBloc(getOutletUsersUsecase: sl<GetOutletUsersUsecase>()),
  );
  sl.registerFactory(
    () => OutletUserActionBloc(
      assignUserToOutletUsecase: sl<AssignUserToOutletUsecase>(),
      unassignUserFromOutletUsecase: sl<UnassignUserFromOutletUsecase>(),
    ),
  );
}
