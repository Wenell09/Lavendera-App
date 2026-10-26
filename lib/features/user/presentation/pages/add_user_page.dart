import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lavendera/config/typography/app_text_styles.dart';
import 'package:lavendera/features/customer/presentation/pages/widgets/button_widget.dart';
import 'package:lavendera/features/customer/presentation/pages/widgets/text_field_widget.dart';
import 'package:lavendera/features/user/presentation/bloc/action/user_action_bloc.dart';
import 'package:lavendera/features/user/presentation/bloc/user_bloc.dart';

class AddUserPage extends StatefulWidget {
  const AddUserPage({super.key});

  @override
  State<AddUserPage> createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isActive = true;
  bool _obscurePassword = true;

  @override
  void dispose() {
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
        title: Text(
          'Tambah Staff',
          style: AppTextStyles.headlineMedium.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<UserActionBloc, UserActionState>(
        listener: (context, state) {
          if (state is UserActionSuccess) {
            context.read<UserBloc>().add(GetUsersRequest());
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                behavior: SnackBarBehavior.floating,
                dismissDirection: DismissDirection.horizontal,
              ),
            );
          } else if (state is UserActionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
                dismissDirection: DismissDirection.horizontal,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFieldWidget(
                  controller: _nameController,
                  label: 'Nama Lengkap',
                  hint: 'Masukkan nama pengguna',
                  prefixIcon: Icons.person_outline,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Nama wajib diisi';
                    if (v.length < 2 || v.length > 150) {
                      return 'Panjang nama 2-150 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFieldWidget(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'staff@gmail.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email wajib diisi';
                    if (v.length > 255) return 'Max 255 karakter';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFieldWidget(
                  controller: _passwordController,
                  label: 'Kata Sandi',
                  hint: 'Minimal 8 karakter',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.grey.shade500,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Kata sandi wajib diisi';
                    if (v.length < 8 || v.length > 72) {
                      return 'Panjang kata sandi 8-72 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                SwitchListTile(
                  title: const Text('Akun Aktif'),
                  value: _isActive,
                  onChanged: (val) => setState(() => _isActive = val),
                  activeThumbColor: const Color(0xFF4A99AD),
                ),
                const SizedBox(height: 40),
                BlocBuilder<UserActionBloc, UserActionState>(
                  builder: (context, state) {
                    return ButtonWidget(
                      label: 'Simpan Staff',
                      isLoading: state is UserActionLoading,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<UserActionBloc>().add(
                            CreateUserActionRequest(
                              body: {
                                'name': _nameController.text.trim(),
                                'email': _emailController.text.trim(),
                                'password': _passwordController.text,
                                'is_active': _isActive,
                              },
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
