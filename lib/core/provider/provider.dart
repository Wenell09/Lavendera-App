import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:lavendera/features/outlet_user/presentation/bloc/outlet_user/outlet_user_bloc.dart';
import 'package:lavendera/features/outlet_user/presentation/bloc/user_outlet/user_outlet_bloc.dart';
import 'package:lavendera/features/profile/presentation/bloc/profile_detail_bloc.dart';
import 'package:lavendera/features/service/presentation/bloc/action/service_action_bloc.dart';
import 'package:lavendera/features/service/presentation/bloc/service_bloc.dart';
import 'package:lavendera/features/service_category/presentation/bloc/action/service_category_action_bloc.dart';
import 'package:lavendera/features/service_category/presentation/bloc/service_category_bloc.dart';
import 'package:lavendera/features/tenant/presentation/bloc/action/tenant_action_bloc.dart';
import 'package:lavendera/features/tenant/presentation/bloc/detail/tenant_detail_bloc.dart';
import 'package:lavendera/features/user/presentation/bloc/action/user_action_bloc.dart';
import 'package:lavendera/features/user/presentation/bloc/user_bloc.dart';

class Provider {
  static List<BlocProvider> providers = [
    BlocProvider<AuthBloc>(
      create: (_) => sl<AuthBloc>()..add(LoadDataRequest()),
    ),
    BlocProvider<CustomerBloc>(create: (_) => sl<CustomerBloc>()),
    BlocProvider<CustomerActionBloc>(create: (_) => sl<CustomerActionBloc>()),
    BlocProvider<DiscountBloc>(create: (_) => sl<DiscountBloc>()),
    BlocProvider<DiscountActionBloc>(create: (_) => sl<DiscountActionBloc>()),
    BlocProvider<ServiceCategoryBloc>(create: (_) => sl<ServiceCategoryBloc>()),
    BlocProvider<ServiceCategoryActionBloc>(
      create: (_) => sl<ServiceCategoryActionBloc>(),
    ),
    BlocProvider<ServiceBloc>(create: (_) => sl<ServiceBloc>()),
    BlocProvider<ServiceActionBloc>(create: (_) => sl<ServiceActionBloc>()),
    BlocProvider<OutletBloc>(create: (_) => sl<OutletBloc>()),
    BlocProvider<OutletActionBloc>(create: (_) => sl<OutletActionBloc>()),
    BlocProvider<OutletUserBloc>(create: (_) => sl<OutletUserBloc>()),
    BlocProvider<UserOutletBloc>(create: (_) => sl<UserOutletBloc>()),
    BlocProvider<OutletUserActionBloc>(
      create: (_) => sl<OutletUserActionBloc>(),
    ),
    BlocProvider<OutletPaymentMethodBloc>(
      create: (_) => sl<OutletPaymentMethodBloc>(),
    ),
    BlocProvider<OutletPaymentMethodActionBloc>(
      create: (_) => sl<OutletPaymentMethodActionBloc>(),
    ),
    BlocProvider<UserBloc>(create: (_) => sl<UserBloc>()),
    BlocProvider<UserActionBloc>(create: (_) => sl<UserActionBloc>()),
    BlocProvider<OrderBloc>(create: (_) => sl<OrderBloc>()),
    BlocProvider<OrderActionBloc>(create: (_) => sl<OrderActionBloc>()),
    BlocProvider<TenantDetailBloc>(create: (_) => sl<TenantDetailBloc>()),
    BlocProvider<TenantActionBloc>(create: (_) => sl<TenantActionBloc>()),
    BlocProvider<ProfileDetailBloc>(create: (_) => sl<ProfileDetailBloc>()),
  ];
}
