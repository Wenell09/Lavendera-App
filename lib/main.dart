import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lavendera/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:lavendera/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:lavendera/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:lavendera/features/auth/domain/usecases/load_data_usecase.dart';
import 'package:lavendera/features/auth/domain/usecases/login_usecase.dart';
import 'package:lavendera/features/auth/domain/usecases/logout_usecase.dart';
import 'package:lavendera/features/auth/domain/usecases/register_usecase.dart';
import 'package:lavendera/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:lavendera/features/splash/presentation/pages/splash_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(
            loginUsecase: LoginUsecase(
              AuthRepositoryImpl(
                authRemoteDataSource: AuthRemoteDataSource(),
                authLocalDataSource: AuthLocalDataSource(),
              ),
            ),
            registerUsecase: RegisterUsecase(
              AuthRepositoryImpl(
                authRemoteDataSource: AuthRemoteDataSource(),
                authLocalDataSource: AuthLocalDataSource(),
              ),
            ),
            loadDataUsecase: LoadDataUsecase(
              AuthRepositoryImpl(
                authRemoteDataSource: AuthRemoteDataSource(),
                authLocalDataSource: AuthLocalDataSource(),
              ),
            ),
            logoutUsecase: LogoutUsecase(
              AuthRepositoryImpl(
                authRemoteDataSource: AuthRemoteDataSource(),
                authLocalDataSource: AuthLocalDataSource(),
              ),
            ),
          )..add(LoadDataRequest()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'TalentForce',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
        ),
        home: const SplashPage(),
      ),
    );
  }
}
