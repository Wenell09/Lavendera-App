import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lavendera/config/typography/app_text_styles.dart';
import 'package:lavendera/features/outlet/domain/entities/outlet.dart';
import 'package:lavendera/features/outlet_payment_method/domain/entities/outlet_payment_method.dart';
import 'package:lavendera/features/outlet_payment_method/presentation/bloc/action/outlet_payment_method_action_bloc.dart';
import 'package:lavendera/features/outlet_payment_method/presentation/bloc/outlet_payment_method_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddEditOutletPaymentMethodPage extends StatefulWidget {
  final Outlet outlet;
  final OutletPaymentMethod? paymentMethod;

  const AddEditOutletPaymentMethodPage({
    super.key,
    required this.outlet,
    this.paymentMethod,
  });

  @override
  State<AddEditOutletPaymentMethodPage> createState() =>
      _AddEditOutletPaymentMethodPageState();
}

class _AddEditOutletPaymentMethodPageState
    extends State<AddEditOutletPaymentMethodPage> {
  final _formKey = GlobalKey<FormState>();
  late String _type;
  late TextEditingController _providerNameController;
  late TextEditingController _accountNumberController;
  late TextEditingController _accountNameController;
  bool _isActive = true;

  File? _imageFile;
  String? _imageUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _type = widget.paymentMethod?.type ?? 'bank_transfer';
    _providerNameController = TextEditingController(
      text: widget.paymentMethod?.providerName ?? '',
    );
    _accountNumberController = TextEditingController(
      text: widget.paymentMethod?.accountNumber ?? '',
    );
    _accountNameController = TextEditingController(
      text: widget.paymentMethod?.accountName ?? '',
    );
    _isActive = widget.paymentMethod?.isActive ?? true;
    _imageUrl = widget.paymentMethod?.qrImageUrl;
  }

  @override
  void dispose() {
    _providerNameController.dispose();
    _accountNumberController.dispose();
    _accountNameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      await _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;
    setState(() {
      _isUploading = true;
    });
    try {
      final supabase = Supabase.instance.client;
      final fileExt = _imageFile!.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final path = '${widget.outlet.id}/$fileName';
      await supabase.storage
          .from('Lavendera_QRIS')
          .upload(
            path,
            _imageFile!,
            fileOptions: const FileOptions(upsert: false),
          );
      final publicUrl = supabase.storage
          .from('Lavendera_QRIS')
          .getPublicUrl(path);

      if (!mounted) return;
      setState(() {
        _imageUrl = publicUrl;
        _isUploading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengunggah QR: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final body = {
      "type": _type,
      "provider_name": _providerNameController.text.trim(),
      "account_number": _type == 'bank_transfer'
          ? _accountNumberController.text.trim()
          : null,
      "account_name": _accountNameController.text.trim(),
      "qr_image_url": _type == 'qris' ? _imageUrl : null,
      "is_active": _isActive,
    };

    if (widget.paymentMethod == null) {
      context.read<OutletPaymentMethodActionBloc>().add(
        CreateOutletPaymentMethodActionRequest(
          outletId: widget.outlet.id,
          body: body,
        ),
      );
    } else {
      context.read<OutletPaymentMethodActionBloc>().add(
        UpdateOutletPaymentMethodActionRequest(
          outletId: widget.outlet.id,
          paymentMethodId: widget.paymentMethod!.id,
          body: body,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.paymentMethod != null;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
        title: Text(
          isEdit ? 'Edit Metode Pembayaran' : 'Tambah Metode Pembayaran',
          style: AppTextStyles.titleMedium.copyWith(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body:
          BlocListener<
            OutletPaymentMethodActionBloc,
            OutletPaymentMethodActionState
          >(
            listener: (context, state) {
              if (state is OutletPaymentMethodActionSuccess) {
                context.read<OutletPaymentMethodBloc>().add(
                  GetOutletPaymentMethodsRequest(outletId: widget.outlet.id),
                );
                Navigator.pop(context, true);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else if (state is OutletPaymentMethodActionError) {
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tipe Pembayaran',
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('Bank Transfer')),
                            selected: _type == 'bank_transfer',
                            selectedColor: const Color(0xFF4A99AD)
                                .withValues(alpha: 0.2),
                            labelStyle: TextStyle(
                              color: _type == 'bank_transfer'
                                  ? const Color(0xFF4A99AD)
                                  : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _type = 'bank_transfer');
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('QRIS')),
                            selected: _type == 'qris',
                            selectedColor: const Color(0xFF4A99AD)
                                .withValues(alpha: 0.2),
                            labelStyle: TextStyle(
                              color: _type == 'qris'
                                  ? const Color(0xFF4A99AD)
                                  : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                            onSelected: (selected) {
                              if (selected) setState(() => _type = 'qris');
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Nama Provider / Bank',
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _providerNameController,
                      decoration: InputDecoration(
                        hintText: 'cth: BCA, GoPay, Mandiri',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Provider wajib diisi'
                          : null,
                    ),
                    if (_type == 'bank_transfer') ...[
                      const SizedBox(height: 20),
                      Text(
                        'Nomor Rekening',
                        style: AppTextStyles.labelLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _accountNumberController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'cth: 1234567890',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        validator: (value) =>
                            _type == 'bank_transfer' &&
                                (value == null || value.isEmpty)
                            ? 'Nomor rekening wajib diisi untuk transfer bank'
                            : null,
                      ),
                    ],
                    const SizedBox(height: 20),
                    Text(
                      'Atas Nama',
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _accountNameController,
                      decoration: InputDecoration(
                        hintText: 'cth: Laundry Sejahtera',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Atas nama wajib diisi'
                          : null,
                    ),
                    if (_type == 'qris') ...[
                      const SizedBox(height: 20),
                      Text(
                        'Gambar QRIS',
                        style: AppTextStyles.labelLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: _isUploading
                              ? const Center(child: CircularProgressIndicator())
                              : _imageUrl != null && _imageUrl!.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.network(
                                    _imageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Center(
                                              child: Icon(
                                                Icons.broken_image,
                                                color: Colors.grey,
                                              ),
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
                      ),
                    ],
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Status Aktif',
                          style: AppTextStyles.labelLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Switch(
                          value: _isActive,
                          activeTrackColor: const Color(0xFF4A99AD),
                          onChanged: (val) => setState(() => _isActive = val),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A99AD),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _save,
                        child: Text(
                          isEdit ? 'Simpan Perubahan' : 'Tambah Metode',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }
}
