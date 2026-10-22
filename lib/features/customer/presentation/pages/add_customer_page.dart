import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lavendera/config/typography/app_text_styles.dart';
import 'package:lavendera/features/customer/presentation/bloc/customer_bloc.dart';
import 'package:lavendera/features/customer/presentation/bloc/action/customer_action_bloc.dart';
import 'package:lavendera/features/customer/presentation/pages/widgets/button_widget.dart';
import 'package:lavendera/features/customer/presentation/pages/widgets/text_field_widget.dart';

class AddCustomerPage extends StatefulWidget {
  const AddCustomerPage({super.key});

  @override
  State<AddCustomerPage> createState() => _AddCustomerPageState();
}

class _AddCustomerPageState extends State<AddCustomerPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Tambah Pelanggan',
          style: AppTextStyles.headlineMedium.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<CustomerActionBloc, CustomerActionState>(
        listener: (context, state) {
          if (state is CustomerActionSuccess) {
            context.read<CustomerBloc>().add(GetCustomersRequest());
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                behavior: SnackBarBehavior.floating,
                dismissDirection: DismissDirection.horizontal,
              ),
            );
          } else if (state is CustomerActionError) {
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
                  hint: 'Masukkan nama pelanggan',
                  prefixIcon: Icons.person_outline,
                  validator: (v) => v!.isEmpty ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 20),
                TextFieldWidget(
                  controller: _phoneController,
                  label: 'Nomor Telepon',
                  hint: 'Contoh: 628123456789',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (v) =>
                      v!.isEmpty ? 'Nomor telepon wajib diisi' : null,
                ),
                const SizedBox(height: 20),
                TextFieldWidget(
                  controller: _addressController,
                  label: 'Alamat (Opsional)',
                  hint: 'Masukkan alamat lengkap',
                  prefixIcon: Icons.location_on_outlined,
                  maxLines: 3,
                ),
                const SizedBox(height: 40),
                BlocBuilder<CustomerActionBloc, CustomerActionState>(
                  builder: (context, state) {
                    return ButtonWidget(
                      label: 'Simpan Pelanggan',
                      isLoading: state is CustomerActionLoading,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<CustomerActionBloc>().add(
                                CreateCustomerActionRequest(
                                  body: {
                                    'name': _nameController.text,
                                    'phone': _phoneController.text,
                                    'address': _addressController.text,
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
