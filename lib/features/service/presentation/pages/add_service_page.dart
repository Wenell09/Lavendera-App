import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lavendera/config/typography/app_text_styles.dart';
import 'package:lavendera/core/di/injection.dart';
import 'package:lavendera/core/utils/currency_formatter.dart';
import 'package:lavendera/features/service/presentation/bloc/action/service_action_bloc.dart';
import 'package:lavendera/features/service_category/domain/entities/service_category.dart';
import 'package:lavendera/features/service_category/domain/usecases/get_service_categories_usecase.dart';

import '../bloc/service_bloc.dart';

class AddServicePage extends StatefulWidget {
  const AddServicePage({super.key});

  @override
  State<AddServicePage> createState() => _AddServicePageState();
}

class _AddServicePageState extends State<AddServicePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _minQuantityController = TextEditingController(text: '1');
  final _durationDaysController = TextEditingController(text: '1');

  String? _selectedCategoryId;
  String _unit = 'kg';
  bool _isActive = true;

  List<ServiceCategory> _categories = [];
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await sl<GetServiceCategoriesUsecase>().call();
      setState(() {
        _categories = categories;
        _isLoadingCategories = false;
        if (_categories.isNotEmpty) {
          _selectedCategoryId = _categories.first.id;
        }
      });
    } catch (_) {
      setState(() {
        _isLoadingCategories = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _minQuantityController.dispose();
    _durationDaysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tambah Layanan',
          style: AppTextStyles.headlineMedium.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<ServiceActionBloc, ServiceActionState>(
        listener: (context, state) {
          if (state is ServiceActionSuccess) {
            context.read<ServiceBloc>().add(GetServicesRequest());
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                behavior: SnackBarBehavior.floating,
                dismissDirection: DismissDirection.horizontal,
              ),
            );
          } else if (state is ServiceActionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: colorScheme.error,
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
                // Category Dropdown
                Text(
                  'Kategori Layanan',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                _isLoadingCategories
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      )
                    : DropdownButtonFormField<String>(
                        initialValue: _selectedCategoryId,
                        isExpanded: true,
                        dropdownColor: colorScheme.surfaceContainer,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: colorScheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText: _categories.isEmpty
                              ? 'Belum ada kategori'
                              : 'Pilih Kategori',
                          hintStyle: AppTextStyles.bodyMedium.copyWith(
                            color: colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.7),
                          ),
                          prefixIcon: Icon(
                            Icons.category_outlined,
                            size: 20,
                            color: colorScheme.primary,
                          ),
                          filled: true,
                          fillColor: Theme.of(context).brightness ==
                                  Brightness.dark
                              ? colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.3)
                              : colorScheme.surfaceContainerLowest,
                          contentPadding: const EdgeInsets.all(16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? colorScheme.outlineVariant
                                      .withValues(alpha: 0.3)
                                  : colorScheme.outlineVariant
                                      .withValues(alpha: 0.5),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: colorScheme.primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                        items: _categories.map((cat) {
                          return DropdownMenuItem<String>(
                            value: cat.id,
                            child: Text(cat.name),
                          );
                        }).toList(),
                        validator: (value) =>
                            value == null ? 'Kategori wajib dipilih' : null,
                        onChanged: (val) {
                          setState(() {
                            _selectedCategoryId = val;
                          });
                        },
                      ),
                const SizedBox(height: 20),

                // Name
                _buildTextField(
                  context: context,
                  controller: _nameController,
                  label: 'Nama Layanan',
                  hint: 'Contoh: Cuci Setrika Reguler',
                  icon: Icons.label_outline,
                  validator: (v) {
                    final trimmed = v?.trim() ?? '';
                    if (trimmed.isEmpty) return 'Nama layanan wajib diisi';
                    if (trimmed.length < 3) {
                      return 'Nama layanan minimal 3 karakter';
                    }
                    if (trimmed.length > 255) {
                      return 'Nama layanan maksimal 255 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Unit Selector
                Text(
                  'Satuan Unit',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildUnitOption(context, 'kg', 'Kg')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildUnitOption(context, 'pcs', 'Pcs')),
                    const SizedBox(width: 8),
                    Expanded(
                      child:
                          _buildUnitOption(context, 'pair', 'Pasang (Pair)'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Price
                _buildTextField(
                  context: context,
                  controller: _priceController,
                  label: 'Harga (Rp)',
                  hint: 'Contoh: 8.000',
                  icon: Icons.payments_outlined,
                  keyboardType: TextInputType.number,
                  inputFormatters: [CurrencyInputFormatter()],
                  validator: (v) {
                    final trimmed = v?.trim() ?? '';

                    if (trimmed.isEmpty) {
                      return 'Harga wajib diisi';
                    }

                    final parsed = int.tryParse(trimmed.replaceAll('.', ''));

                    if (parsed == null || parsed < 0) {
                      return 'Harga tidak boleh kurang dari 0';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Min Quantity & Duration in Days
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        context: context,
                        controller: _minQuantityController,
                        label: 'Jumlah Minimum',
                        hint: '1',
                        icon: Icons.format_list_numbered,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          final trimmed = v?.trim() ?? '';
                          if (trimmed.isEmpty) {
                            return 'Jumlah min wajib diisi';
                          }
                          final parsed = num.tryParse(trimmed);
                          if (parsed == null || parsed <= 0) {
                            return 'Minimal harus > 0';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        context: context,
                        controller: _durationDaysController,
                        label: 'Durasi (Hari)',
                        hint: '2',
                        icon: Icons.timer_outlined,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          final trimmed = v?.trim() ?? '';
                          if (trimmed.isEmpty) {
                            return 'Durasi hari wajib diisi';
                          }
                          final parsed = int.tryParse(trimmed);
                          if (parsed == null || parsed <= 0) {
                            return 'Durasi harus > 0';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Active Switch
                SwitchListTile(
                  title: Text(
                    'Status Aktif',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  value: _isActive,
                  activeThumbColor: colorScheme.primary,
                  onChanged: (v) => setState(() => _isActive = v),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 40),

                // Submit Button
                _buildSubmitButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUnitOption(BuildContext context, String val, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    bool isSelected = _unit == val;

    return GestureDetector(
      onTap: () => setState(() => _unit = val),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.15)
              : (isDark
                  ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
                  : Colors.grey.shade50),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : (isDark
                    ? colorScheme.outlineVariant.withValues(alpha: 0.3)
                    : Colors.grey.shade200),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          style: AppTextStyles.bodyLarge.copyWith(
            color: colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            prefixIcon: Icon(icon, size: 20, color: colorScheme.primary),
            filled: true,
            fillColor: isDark
                ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
                : colorScheme.surfaceContainerLowest,
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDark
                    ? colorScheme.outlineVariant.withValues(alpha: 0.3)
                    : colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: colorScheme.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<ServiceActionBloc, ServiceActionState>(
      builder: (context, state) {
        final isLoading = state is ServiceActionLoading;
        return ElevatedButton(
          onPressed: isLoading
              ? null
              : () {
                  if (_formKey.currentState!.validate()) {
                    final cleanPrice =
                        int.tryParse(
                          _priceController.text.replaceAll('.', ''),
                        ) ??
                        0;
                    context.read<ServiceActionBloc>().add(
                      CreateServiceActionRequest(
                        body: {
                          'category_id': _selectedCategoryId,
                          'name': _nameController.text.trim(),
                          'price': cleanPrice,
                          'min_quantity':
                              num.tryParse(_minQuantityController.text) ?? 1,
                          'unit': _unit,
                          'duration_days':
                              int.tryParse(_durationDaysController.text) ?? 1,
                          'is_active': _isActive,
                        },
                      ),
                    );
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.onPrimary,
                  ),
                )
              : Text(
                  'Simpan Layanan',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
        );
      },
    );
  }
}
