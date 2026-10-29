import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lavendera/config/colors/app_colors.dart';
import 'package:lavendera/config/typography/app_text_styles.dart';
import 'package:lavendera/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:lavendera/features/auth/presentation/pages/register_page.dart';
import 'package:lavendera/features/auth/presentation/pages/widgets/button_widget.dart';
import 'package:lavendera/features/auth/presentation/pages/widgets/text_field_widget.dart';
import 'package:lavendera/features/navigation/presentation/pages/navigation_page.dart';
import 'package:lavendera/features/profile/presentation/bloc/profile_detail_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoaded) {
            context.read<ProfileDetailBloc>().add(GetProfileRequest());
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const NavigationPage()),
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Login failed. Please check your credentials.'),
                backgroundColor: Colors.redAccent,
                dismissDirection: DismissDirection.horizontal,
              ),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 84,
                          height: 84,
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              'assets/images/lavendera.jpeg',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        'Welcome Back',
                        style: AppTextStyles.displaySmall.copyWith(
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to continue to Lavendera',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 32),
                      TextFieldWidget(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'budi@laundrysejahtera.com',
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFieldWidget(
                        controller: _passwordController,
                        label: 'Password',
                        hint: '••••••••',
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          } else if (value.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      ButtonWidget(
                        label: 'Login',
                        isLoading: state is AuthLoading,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            context.read<AuthBloc>().add(
                              LoginRequest(
                                email: _emailController.text.trim(),
                                password: _passwordController.text,
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const RegisterPage(),
                                ),
                              );
                            },
                            child: Text(
                              'Register',
                              style: AppTextStyles.titleMedium.copyWith(
                                color: AppColors.blue.color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
