import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lavendera/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:lavendera/features/auth/presentation/pages/login_page.dart';
import 'package:lavendera/features/navigation/presentation/pages/navigation_page.dart';
import 'package:lavendera/features/profile/presentation/bloc/profile_detail_bloc.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        }
        if (state is AuthLoaded) {
          context.read<ProfileDetailBloc>().add(GetProfileRequest());
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const NavigationPage()),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                'assets/images/lavendera.jpeg',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
