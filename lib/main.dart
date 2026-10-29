import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lavendera/config/supabase/supabase_url.dart';
import 'package:lavendera/config/theme/app_theme.dart';
import 'package:lavendera/core/di/injection.dart';
import 'package:lavendera/core/provider/provider.dart';
import 'package:lavendera/features/splash/presentation/pages/splash_page.dart';
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
      providers: Provider.providers,
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
