import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lavendera/config/supabase/supabase_url.dart';
import 'package:lavendera/config/theme/app_theme.dart';
import 'package:lavendera/core/di/injection.dart';
import 'package:lavendera/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:lavendera/features/customer/presentation/bloc/action/customer_action_bloc.dart';
import 'package:lavendera/features/customer/presentation/bloc/customer_bloc.dart';
import 'package:lavendera/features/discount/presentation/bloc/action/discount_action_bloc.dart';
import 'package:lavendera/features/discount/presentation/bloc/discount_bloc.dart';
import 'package:lavendera/features/order/presentation/bloc/action/order_action_bloc.dart';
import 'package:lavendera/features/order/presentation/bloc/order_bloc.dart';
import 'package:lavendera/features/outlet/presentation/bloc/action/outlet_action_bloc.dart';
import 'package:lavendera/features/outlet/presentation/bloc/outlet_bloc.dart';
import 'package:lavendera/features/outlet_payment_method/presentation/bloc/action/outlet_payment_method_action_bloc.dart';
import 'package:lavendera/features/outlet_payment_method/presentation/bloc/outlet_payment_method_bloc.dart';
import 'package:lavendera/features/outlet_user/presentation/bloc/action/outlet_user_action_bloc.dart';
import 'package:lavendera/features/outlet_user/presentation/bloc/outlet_user_bloc.dart';
import 'package:lavendera/features/profile/presentation/bloc/profile_detail_bloc.dart';
import 'package:lavendera/features/service/presentation/bloc/action/service_action_bloc.dart';
import 'package:lavendera/features/service/presentation/bloc/service_bloc.dart';
import 'package:lavendera/features/service_category/presentation/bloc/action/service_category_action_bloc.dart';
import 'package:lavendera/features/service_category/presentation/bloc/service_category_bloc.dart';
import 'package:lavendera/features/splash/presentation/pages/splash_page.dart';
import 'package:lavendera/features/tenant/presentation/bloc/action/tenant_action_bloc.dart';
import 'package:lavendera/features/tenant/presentation/bloc/detail/tenant_detail_bloc.dart';
import 'package:lavendera/features/user/presentation/bloc/action/user_action_bloc.dart';
import 'package:lavendera/features/user/presentation/bloc/user_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(url: url, publishableKey: publishableKey);
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
        BlocProvider(create: (_) => sl<OutletUserBloc>()),
        BlocProvider(create: (_) => sl<OutletUserActionBloc>()),
        BlocProvider(create: (_) => sl<OutletPaymentMethodBloc>()),
        BlocProvider(create: (_) => sl<OutletPaymentMethodActionBloc>()),
        BlocProvider(create: (_) => sl<UserBloc>()),
        BlocProvider(create: (_) => sl<UserActionBloc>()),
        BlocProvider(create: (_) => sl<OrderBloc>()),
        BlocProvider(create: (_) => sl<OrderActionBloc>()),
        BlocProvider(create: (_) => sl<TenantDetailBloc>()),
        BlocProvider(create: (_) => sl<TenantActionBloc>()),
        BlocProvider(create: (_) => sl<ProfileDetailBloc>()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Lavendera',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        home: const SplashPage(),
      ),
    );
  }
}
