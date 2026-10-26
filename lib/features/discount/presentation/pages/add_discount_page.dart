import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lavendera/config/typography/app_text_styles.dart';
import 'package:lavendera/core/utils/currency_formatter.dart';
import 'package:lavendera/features/discount/presentation/bloc/action/discount_action_bloc.dart';
import 'package:lavendera/features/discount/presentation/bloc/discount_bloc.dart';

class AddDiscountPage extends StatefulWidget {
  const AddDiscountPage({super.key});

  @override
  State<AddDiscountPage> createState() => _AddDiscountPageState();
}

class _AddDiscountPageState extends State<AddDiscountPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _valueController = TextEditingController();
  String _type = 'percentage';
  bool _isActive = true;

  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Tambah Diskon',
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
      body: BlocListener<DiscountActionBloc, DiscountActionState>(
        listener: (context, state) {
          if (state is DiscountActionSuccess) {
            context.read<DiscountBloc>().add(GetDiscountsRequest());
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                behavior: SnackBarBehavior.floating,
                dismissDirection: DismissDirection.horizontal,
              ),
            );
          } else if (state is DiscountActionError) {
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
                  label: 'Nama Diskon',
                  hint: 'Contoh: Promo Kemerdekaan',
                  icon: Icons.label_outline,
                  validator: (v) => v!.isEmpty ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 20),
                Text(
                  'Tipe Diskon',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildTypeOption('percentage', 'Persentase (%)'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTypeOption('fixed', 'Nominal (Rp)')),
                  ],
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _valueController,
                  label: 'Nilai Diskon',
                  hint: _type == 'percentage' ? 'Contoh: 15' : 'Contoh: 10.000',
                  icon: _type == 'percentage'
                      ? Icons.percent
                      : Icons.account_balance_wallet_outlined,
                  keyboardType: TextInputType.number,
                  inputFormatters: _type == 'fixed'
                      ? [CurrencyInputFormatter()]
                      : [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) {
                    final trimmed = v?.trim() ?? '';
                    if (trimmed.isEmpty) return 'Nilai wajib diisi';
                    final cleanValue = _type == 'fixed'
                        ? trimmed.replaceAll('.', '')
                        : trimmed;
                    final parsed = num.tryParse(cleanValue);
                    if (parsed == null || parsed <= 0) {
                      return 'Nilai harus lebih dari 0';
                    }
                    if (_type == 'percentage' && parsed > 100) {
                      return 'Persentase tidak boleh lebih dari 100';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                SwitchListTile(
                  title: Text(
                    'Status Aktif',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  value: _isActive,
                  activeThumbColor: const Color(0xFF4A99AD),
                  onChanged: (v) => setState(() => _isActive = v),
                  contentPadding: EdgeInsets.zero,
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

  Widget _buildTypeOption(String val, String label) {
    bool isSelected = _type == val;
    return GestureDetector(
      onTap: () {
        setState(() {
          _type = val;
          _valueController.clear();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4A99AD).withValues(alpha: 0.1)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF4A99AD) : Colors.grey.shade200,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: isSelected ? const Color(0xFF4A99AD) : Colors.black54,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
    List<TextInputFormatter>? inputFormatters,
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
          inputFormatters: inputFormatters,
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
    return BlocBuilder<DiscountActionBloc, DiscountActionState>(
      builder: (context, state) {
        final isLoading = state is DiscountActionLoading;
        return ElevatedButton(
          onPressed: isLoading
              ? null
              : () {
                  if (_formKey.currentState!.validate()) {
                    final cleanValue = _type == 'fixed'
                        ? _valueController.text.replaceAll('.', '')
                        : _valueController.text;
                    context.read<DiscountActionBloc>().add(
                      CreateDiscountActionRequest(
                        body: {
                          'name': _nameController.text,
                          'type': _type,
                          'value': num.tryParse(cleanValue) ?? 0,
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
                  'Simpan Diskon',
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
