import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lavendera/config/typography/app_text_styles.dart';

class PaymentMethodForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final String type;
  final TextEditingController providerNameController;
  final TextEditingController accountNumberController;
  final TextEditingController accountNameController;
  final bool isActive;
  final bool isLoading;
  final File? imageFile;
  final String? imageUrl;
  final bool isUploading;
  final Function(String) onTypeChanged;
  final Function(bool) onStatusChanged;
  final VoidCallback onPickImage;
  final VoidCallback? onDeleteImage;
  final VoidCallback onSave;
  final bool isEdit;

  const PaymentMethodForm({
    super.key,
    required this.formKey,
    required this.type,
    required this.providerNameController,
    required this.accountNumberController,
    required this.accountNameController,
    required this.isActive,
    required this.isLoading,
    this.imageFile,
    this.imageUrl,
    this.onDeleteImage,
    required this.isUploading,
    required this.onTypeChanged,
    required this.onStatusChanged,
    required this.onPickImage,
    required this.onSave,
    required this.isEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildLabel(context, 'Tipe Pembayaran'),
          const SizedBox(height: 8),
          _buildTypeSelector(context),
          const SizedBox(height: 20),
          _buildLabel(context, 'Nama Provider / Bank'),
          const SizedBox(height: 8),
          _buildTextField(
            context: context,
            icon: Icons.account_balance,
            controller: providerNameController,
            hint: 'cth: BCA, GoPay, Mandiri',
            validator: (value) =>
                value == null || value.isEmpty ? 'Provider wajib diisi' : null,
          ),
          if (type == 'bank_transfer') ...[
            const SizedBox(height: 20),
            _buildLabel(context, 'Nomor Rekening'),
            const SizedBox(height: 8),
            _buildTextField(
              context: context,
              icon: Icons.account_balance_wallet,
              controller: accountNumberController,
              hint: 'cth: 1234567890',
              keyboardType: TextInputType.number,
              validator: (value) =>
                  type == 'bank_transfer' && (value == null || value.isEmpty)
                  ? 'Nomor rekening wajib diisi untuk transfer bank'
                  : null,
            ),
          ],
          const SizedBox(height: 20),
          _buildLabel(context, 'Atas Nama'),
          const SizedBox(height: 8),
          _buildTextField(
            context: context,
            icon: Icons.account_box,
            controller: accountNameController,
            hint: 'cth: Laundry Sejahtera',
            validator: (value) =>
                value == null || value.isEmpty ? 'Atas nama wajib diisi' : null,
          ),
          if (type == 'qris') ...[
            const SizedBox(height: 20),
            _buildLabel(context, 'Gambar QRIS'),
            const SizedBox(height: 8),
            _buildQRISUploader(context),
          ],
          const SizedBox(height: 20),
          _buildStatusSwitch(context),
          const SizedBox(height: 40),
          _buildSubmitButton(context, isLoading),
        ],
      ),
    );
  }

  Widget _buildLabel(BuildContext context, String text) {
    final colorScheme = Theme.of(context).colorScheme;
    return Text(
      text,
      style: AppTextStyles.labelLarge.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTypeSelector(BuildContext context) {
    return Row(
      children: [
        _buildTypeChip(context, 'Bank Transfer', 'bank_transfer'),
        const SizedBox(width: 12),
        _buildTypeChip(context, 'QRIS', 'qris'),
      ],
    );
  }

  Widget _buildTypeChip(BuildContext context, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final isSelected = type == value;

    return Expanded(
      child: ChoiceChip(
        label: Center(child: Text(label)),
        selected: isSelected,
        backgroundColor: isDark
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
            : colorScheme.surfaceContainerLowest,
        selectedColor: colorScheme.primary.withValues(alpha: 0.2),
        labelStyle: TextStyle(
          color: isSelected ? colorScheme.primary : colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
        side: BorderSide(
          color: isSelected
              ? colorScheme.primary
              : (isDark
                    ? colorScheme.outlineVariant.withValues(alpha: 0.3)
                    : colorScheme.outlineVariant.withValues(alpha: 0.5)),
        ),
        onSelected: (selected) {
          if (selected) onTypeChanged(value);
        },
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: AppTextStyles.bodyLarge.copyWith(color: colorScheme.onSurface),
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
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildQRISUploader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final hasImage =
        imageFile != null || (imageUrl != null && imageUrl!.isNotEmpty);
    return Stack(
      children: [
        GestureDetector(
          onTap: onPickImage,
          child: Container(
            height: 350,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark
                  ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
                  : colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? colorScheme.outlineVariant.withValues(alpha: 0.3)
                    : colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: isUploading
                ? Center(
                    child: CircularProgressIndicator(
                      color: colorScheme.primary,
                    ),
                  )
                : imageFile != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(imageFile!, fit: BoxFit.cover),
                  )
                : imageUrl != null && imageUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Icon(
                          Icons.broken_image,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.qr_code_scanner,
                        size: 40,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ketuk untuk unggah QRIS',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
          ),
        ),
        if (hasImage && onDeleteImage != null && !isUploading)
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: onDeleteImage,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: colorScheme.error,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, size: 16, color: colorScheme.onError),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusSwitch(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildLabel(context, 'Status Aktif'),
        Switch(
          value: isActive,
          activeTrackColor: colorScheme.primary,
          onChanged: onStatusChanged,
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context, bool isLoading) {
    final colorScheme = Theme.of(context).colorScheme;
    return ElevatedButton(
      onPressed: isLoading ? null : onSave,
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              isEdit ? 'Perbarui Metode' : 'Simpan Metode',
              style: AppTextStyles.labelLarge.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
    );
  }
}
