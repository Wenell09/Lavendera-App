import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lavendera/config/colors/app_colors.dart';
import 'package:lavendera/config/typography/app_text_styles.dart';
import 'package:lavendera/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:lavendera/features/auth/presentation/pages/widgets/button_widget.dart';
import 'package:lavendera/features/auth/presentation/pages/widgets/text_field_widget.dart';
import 'package:lavendera/features/navigation/presentation/pages/navigation_page.dart';
import 'package:lavendera/features/profile/presentation/bloc/profile_detail_bloc.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tenantNameController;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _tenantNameController = TextEditingController();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _tenantNameController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoaded) {
            context.read<ProfileDetailBloc>().add(GetProfileRequest());
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const NavigationPage()),
              (route) => false,
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Registration failed. Please try again.'),
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
                          width: 76,
                          height: 76,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.asset(
                              'assets/images/lavendera.jpeg',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        'Create Account',
                        style: AppTextStyles.displaySmall.copyWith(
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Register your laundry business to get started',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 28),
                      TextFieldWidget(
                        controller: _tenantNameController,
                        label: 'Tenant Name',
                        hint: 'Laundry Sejahtera',
                        validator: (value) {
                          if (value == null || value.trim().length < 3) {
                            return 'Tenant name must be at least 3 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFieldWidget(
                        controller: _nameController,
                        label: 'Full Name',
                        hint: 'Budi Santoso',
                        validator: (value) {
                          if (value == null || value.trim().length < 2) {
                            return 'Name must be at least 2 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFieldWidget(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'budi@laundrysejahtera.com',
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || !value.contains('@')) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
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
                          if (value == null || value.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),
                      ButtonWidget(
                        label: 'Register',
                        isLoading: state is AuthLoading,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            context.read<AuthBloc>().add(
                              RegisterRequest(
                                data: {
                                  'tenant_name': _tenantNameController.text
                                      .trim(),
                                  'name': _nameController.text.trim(),
                                  'email': _emailController.text.trim(),
                                  'password': _passwordController.text,
                                },
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
                            'Already have an account? ',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Text(
                              'Login',
                              style: AppTextStyles.titleMedium.copyWith(
                                color: AppColors.blue.color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
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
