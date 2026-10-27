import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lavendera/config/colors/app_colors.dart';
import 'package:lavendera/config/typography/app_text_styles.dart';
import 'package:lavendera/core/di/injection.dart';
import 'package:lavendera/features/customer/presentation/pages/widgets/text_field_widget.dart';
import 'package:lavendera/features/tenant/domain/entities/tenant.dart';
import 'package:lavendera/features/tenant/presentation/bloc/action/tenant_action_bloc.dart';

class EditTenantPage extends StatefulWidget {
  final Tenant tenant;
  const EditTenantPage({super.key, required this.tenant});

  @override
  State<EditTenantPage> createState() => _EditTenantPageState();
}

class _EditTenantPageState extends State<EditTenantPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _slugController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.tenant.name);
    _slugController = TextEditingController(text: widget.tenant.slug);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _slugController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<TenantActionBloc>(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 20,
              color: Colors.black87,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Edit Bisnis',
            style: AppTextStyles.headlineMedium.copyWith(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: BlocListener<TenantActionBloc, TenantActionState>(
          listener: (context, state) {
            if (state is TenantActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.pop(context, true);
            } else if (state is TenantActionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
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
                  _buildHeaderInfo(),
                  const SizedBox(height: 32),
                  TextFieldWidget(
                    controller: _nameController,
                    label: 'Nama Bisnis',
                    hint: 'Masukkan nama bisnis baru',
                    prefixIcon: Icons.business_outlined,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Nama wajib diisi';
                      if (v.length < 3) return 'Minimal 3 karakter';
                      if (v.length > 100) return 'Maksimal 100 karakter';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFieldWidget(
                    controller: _slugController,
                    label: 'Slug / URL',
                    hint: 'masukkan-slug-baru',
                    prefixIcon: Icons.link_outlined,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Slug wajib diisi';
                      if (v.length < 3) return 'Minimal 3 karakter';
                      if (v.length > 100) return 'Maksimal 100 karakter';
                      if (!RegExp(r'^[a-z0-9\-]+$').hasMatch(v)) {
                        return 'Hanya boleh huruf kecil, angka, dan tanda hubung (-)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Catatan: Mengubah slug akan mengubah URL akses bisnis Anda.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 40),
                  BlocBuilder<TenantActionBloc, TenantActionState>(
                    builder: (context, state) {
                      final isLoading = state is TenantActionLoading;
                      return ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  context.read<TenantActionBloc>().add(
                                    UpdateTenantActionRequest(
                                      id: widget.tenant.id,
                                      body: {
                                        if (_nameController.text !=
                                            widget.tenant.name)
                                          'name': _nameController.text,
                                        if (_slugController.text !=
                                            widget.tenant.slug)
                                          'slug': _slugController.text,
                                      },
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue.color,
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
      ),
    );
  }

  Widget _buildHeaderInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Informasi Penting',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: Colors.blue.shade900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Email admin (${widget.tenant.email}) tidak dapat diubah.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
