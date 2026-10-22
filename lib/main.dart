import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lavendera/core/di/injection.dart';
import 'package:lavendera/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:lavendera/features/customer/presentation/bloc/action/customer_action_bloc.dart';
import 'package:lavendera/features/customer/presentation/bloc/customer_bloc.dart';
import 'package:lavendera/features/discount/presentation/bloc/action/discount_action_bloc.dart';
import 'package:lavendera/features/discount/presentation/bloc/discount_bloc.dart';
import 'package:lavendera/features/outlet/presentation/bloc/action/outlet_action_bloc.dart';
import 'package:lavendera/features/outlet/presentation/bloc/outlet_bloc.dart';
import 'package:lavendera/features/service/presentation/bloc/action/service_action_bloc.dart';
import 'package:lavendera/features/service/presentation/bloc/service_bloc.dart';
import 'package:lavendera/features/service_category/presentation/bloc/action/service_category_action_bloc.dart';
import 'package:lavendera/features/service_category/presentation/bloc/service_category_bloc.dart';
import 'package:lavendera/features/splash/presentation/pages/splash_page.dart';
import 'package:lavendera/features/user/presentation/bloc/action/user_action_bloc.dart';
import 'package:lavendera/features/user/presentation/bloc/user_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AuthBloc>()..add(LoadDataRequest())),
        BlocProvider(create: (_) => sl<CustomerBloc>()),
        BlocProvider(create: (_) => sl<CustomerActionBloc>()),
        BlocProvider(create: (_) => sl<DiscountBloc>()),
        BlocProvider(create: (_) => sl<DiscountActionBloc>()),
        BlocProvider(create: (_) => sl<ServiceCategoryBloc>()),
        BlocProvider(create: (_) => sl<ServiceCategoryActionBloc>()),
        BlocProvider(create: (_) => sl<ServiceBloc>()),
        BlocProvider(create: (_) => sl<ServiceActionBloc>()),
        BlocProvider(create: (_) => sl<OutletBloc>()),
        BlocProvider(create: (_) => sl<OutletActionBloc>()),
        BlocProvider(create: (_) => sl<UserBloc>()),
        BlocProvider(create: (_) => sl<UserActionBloc>()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Lavendera',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
        ),
        home: const SplashPage(),
      ),
    );
  }
}
