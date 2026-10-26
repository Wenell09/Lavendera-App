import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lavendera/config/typography/app_text_styles.dart';
import 'package:lavendera/features/outlet/presentation/bloc/action/outlet_action_bloc.dart';
import 'package:lavendera/features/outlet/presentation/bloc/outlet_bloc.dart';

class AddOutletPage extends StatefulWidget {
  const AddOutletPage({super.key});

  @override
  State<AddOutletPage> createState() => _AddOutletPageState();
}

class _AddOutletPageState extends State<AddOutletPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isPublicOrderEnabled = true;
  bool _isActive = true;

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
          'Tambah Outlet',
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
      body: BlocListener<OutletActionBloc, OutletActionState>(
        listener: (context, state) {
          if (state is OutletActionSuccess) {
            context.read<OutletBloc>().add(GetOutletsRequest());
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                behavior: SnackBarBehavior.floating,
                dismissDirection: DismissDirection.horizontal,
              ),
            );
          } else if (state is OutletActionError) {
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
                _buildTextField(
                  controller: _nameController,
                  label: 'Nama Outlet',
                  hint: 'Contoh: Outlet Cabang Melati',
                  icon: Icons.storefront_outlined,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Nama outlet wajib diisi';
                    }
                    if (v.trim().length < 5) {
                      return 'Nama minimal 5 karakter';
                    }
                    if (v.trim().length > 255) {
                      return 'Nama maksimal 255 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _phoneController,
                  label: 'Nomor HP',
                  hint: 'Contoh: 6281234567890',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _addressController,
                  label: 'Alamat',
                  hint: 'Contoh: Jl. Melati No. 12, Jakarta',
                  icon: Icons.location_on_outlined,
                  maxLines: 3,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Alamat wajib diisi'
                      : null,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: Text(
                          'Order Publik Aktif',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'Izinkan order publik untuk outlet ini',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                        value: _isPublicOrderEnabled,
                        activeThumbColor: const Color(0xFF4A99AD),
                        onChanged: (v) =>
                            setState(() => _isPublicOrderEnabled = v),
                        contentPadding: EdgeInsets.zero,
                      ),
                      Divider(color: Colors.grey.shade200, height: 1),
                      SwitchListTile(
                        title: Text(
                          'Status Aktif',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'Status operasional outlet',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                        value: _isActive,
                        activeThumbColor: const Color(0xFF4A99AD),
                        onChanged: (v) => setState(() => _isActive = v),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: AppTextStyles.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: Colors.grey.shade400,
            ),
            prefixIcon: Icon(icon, size: 20, color: const Color(0xFF4A99AD)),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade100),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFF4A99AD),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<OutletActionBloc, OutletActionState>(
      builder: (context, state) {
        final isLoading = state is OutletActionLoading;
        return ElevatedButton(
          onPressed: isLoading
              ? null
              : () {
                  if (_formKey.currentState!.validate()) {
                    context.read<OutletActionBloc>().add(
                      CreateOutletActionRequest(
                        body: {
                          'name': _nameController.text.trim(),
                          'phone': _phoneController.text.trim(),
                          'address': _addressController.text.trim(),
                          'is_public_order_enabled': _isPublicOrderEnabled,
                          'is_active': _isActive,
                        },
                      ),
                    );
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4A99AD),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  'Simpan Outlet',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
        );
      },
    );
  }
}
