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
  final String? imageUrl;
  final bool isUploading;
  final Function(String) onTypeChanged;
  final Function(bool) onStatusChanged;
  final VoidCallback onPickImage;
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
    this.imageUrl,
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
          _buildLabel('Tipe Pembayaran'),
          const SizedBox(height: 8),
          _buildTypeSelector(),
          const SizedBox(height: 20),
          _buildLabel('Nama Provider / Bank'),
          const SizedBox(height: 8),
          _buildTextField(
            icon: Icons.account_balance,
            controller: providerNameController,
            hint: 'cth: BCA, GoPay, Mandiri',
            validator: (value) =>
                value == null || value.isEmpty ? 'Provider wajib diisi' : null,
          ),
          if (type == 'bank_transfer') ...[
            const SizedBox(height: 20),
            _buildLabel('Nomor Rekening'),
            const SizedBox(height: 8),
            _buildTextField(
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
          _buildLabel('Atas Nama'),
          const SizedBox(height: 8),
          _buildTextField(
            icon: Icons.account_box,
            controller: accountNameController,
            hint: 'cth: Laundry Sejahtera',
            validator: (value) =>
                value == null || value.isEmpty ? 'Atas nama wajib diisi' : null,
          ),
          if (type == 'qris') ...[
            const SizedBox(height: 20),
            _buildLabel('Gambar QRIS'),
            const SizedBox(height: 8),
            _buildQRISUploader(),
          ],
          const SizedBox(height: 20),
          _buildStatusSwitch(),
          const SizedBox(height: 40),
          _buildSubmitButton(isLoading),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildTypeSelector() {
    return Row(
      children: [
        _buildTypeChip('Bank Transfer', 'bank_transfer'),
        const SizedBox(width: 12),
        _buildTypeChip('QRIS', 'qris'),
      ],
    );
  }

  Widget _buildTypeChip(String label, String value) {
    final isSelected = type == value;
    return Expanded(
      child: ChoiceChip(
        label: Center(child: Text(label)),
        selected: isSelected,
        backgroundColor: Colors.grey.shade100,
        selectedColor: const Color(0xFF4A99AD).withValues(alpha: 0.2),
        labelStyle: TextStyle(
          color: isSelected ? const Color(0xFF4A99AD) : Colors.black87,
          fontWeight: FontWeight.bold,
        ),
        onSelected: (selected) {
          if (selected) onTypeChanged(value);
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
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
          borderSide: const BorderSide(color: Color(0xFF4A99AD), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildQRISUploader() {
    return GestureDetector(
      onTap: onPickImage,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: isUploading
            ? const Center(child: CircularProgressIndicator())
            : imageUrl != null && imageUrl!.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.qr_code_scanner,
                    size: 40,
                    color: Color(0xFF4A99AD),
                  ),
                  SizedBox(height: 8),
                  Text('Ketuk untuk unggah QRIS'),
                ],
              ),
      ),
    );
  }

  Widget _buildStatusSwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildLabel('Status Aktif'),
        Switch(
          value: isActive,
          activeTrackColor: const Color(0xFF4A99AD),
          onChanged: onStatusChanged,
        ),
      ],
    );
  }

  Widget _buildSubmitButton(bool isLoading) {
    return ElevatedButton(
      onPressed: isLoading ? null : onSave,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4A99AD),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              isEdit ? 'Perbarui Metode' : 'Simpan Metode',
              style: AppTextStyles.labelLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
    );
  }
}
