import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lavendera/config/typography/app_text_styles.dart';
import 'package:lavendera/features/outlet/domain/entities/outlet.dart';
import 'package:lavendera/features/outlet/presentation/bloc/action/outlet_action_bloc.dart';

class EditOutletPage extends StatefulWidget {
  final Outlet outlet;
  const EditOutletPage({super.key, required this.outlet});

  @override
  State<EditOutletPage> createState() => _EditOutletPageState();
}

class _EditOutletPageState extends State<EditOutletPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _slugController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late bool _isPublicOrderEnabled;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.outlet.name);
    _slugController = TextEditingController(text: widget.outlet.slug);
    _phoneController = TextEditingController(text: widget.outlet.phone);
    _addressController = TextEditingController(text: widget.outlet.address);
    _isPublicOrderEnabled = widget.outlet.isPublicOrderEnabled;
    _isActive = widget.outlet.isActive;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _slugController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  String sanitizeToSlug(String text) {
    return text
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Edit Outlet',
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
            Navigator.pop(context, true);
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
                  hint: 'Masukkan nama outlet',
                  icon: Icons.storefront_outlined,
                  validator: (v) => v!.isEmpty ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _slugController,
                  label: 'Slug',
                  hint: 'Masukkan slug outlet',
                  icon: Icons.link_outlined,
                  validator: (v) => v!.isEmpty ? 'Slug wajib diisi' : null,
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
                  hint: 'Masukkan alamat lengkap',
                  icon: Icons.location_on_outlined,
                  maxLines: 3,
                  validator: (v) => v!.isEmpty ? 'Alamat wajib diisi' : null,
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
                  child: Material(
                    color: Colors.transparent,
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
                ),
                const SizedBox(height: 40),
                BlocBuilder<OutletActionBloc, OutletActionState>(
                  builder: (context, state) {
                    final isLoading = state is OutletActionLoading;
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          if (!isLoading)
                            BoxShadow(
                              color: const Color(0xFF4A99AD)
                                  .withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  context.read<OutletActionBloc>().add(
                                    UpdateOutletActionRequest(
                                      id: widget.outlet.id,
                                      body: {
                                        'name': _nameController.text.trim(),
                                        'slug': sanitizeToSlug(
                                          _slugController.text,
                                        ),
                                        'phone': _phoneController.text.trim(),
                                        'address': _addressController.text
                                            .trim(),
                                        'is_public_order_enabled':
                                            _isPublicOrderEnabled,
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
                          disabledBackgroundColor: Colors.grey.shade300,
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
                                'Simpan Perubahan',
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
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
          validator: validator,
          maxLines: maxLines,
          style: AppTextStyles.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: Colors.grey.shade400,
            ),
            prefixIcon: Icon(icon, size: 20, color: const Color(0xFF4A99AD)),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1),
            ),
          ),
        ),
      ],
    );
  }
}
