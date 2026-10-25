import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lavendera/config/typography/app_text_styles.dart';
import 'package:lavendera/features/outlet/domain/entities/outlet.dart';
import 'package:lavendera/features/outlet_payment_method/domain/entities/outlet_payment_method.dart';
import 'package:lavendera/features/outlet_payment_method/presentation/bloc/action/outlet_payment_method_action_bloc.dart';
import 'package:lavendera/features/outlet_payment_method/presentation/bloc/outlet_payment_method_bloc.dart';
import 'package:lavendera/features/outlet_payment_method/presentation/pages/widgets/payment_method_form.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditOutletPaymentMethodPage extends StatefulWidget {
  final Outlet outlet;
  final OutletPaymentMethod paymentMethod;

  const EditOutletPaymentMethodPage({
    super.key,
    required this.outlet,
    required this.paymentMethod,
  });

  @override
  State<EditOutletPaymentMethodPage> createState() =>
      _EditOutletPaymentMethodPageState();
}

class _EditOutletPaymentMethodPageState
    extends State<EditOutletPaymentMethodPage> {
  final _formKey = GlobalKey<FormState>();
  late String _type;
  late TextEditingController _providerNameController;
  late TextEditingController _accountNumberController;
  late TextEditingController _accountNameController;
  late bool _isActive;
  File? _imageFile;
  String? _imageUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _type = widget.paymentMethod.type;
    _providerNameController = TextEditingController(
      text: widget.paymentMethod.providerName,
    );
    _accountNumberController = TextEditingController(
      text: widget.paymentMethod.accountNumber ?? '',
    );
    _accountNameController = TextEditingController(
      text: widget.paymentMethod.accountName,
    );
    _isActive = widget.paymentMethod.isActive;
    _imageUrl = widget.paymentMethod.qrImageUrl;
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
      setState(() => _imageFile = File(pickedFile.path));
      await _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;
    setState(() => _isUploading = true);
    try {
      final supabase = Supabase.instance.client;
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}.${_imageFile!.path.split('.').last}';
      final path = '${widget.outlet.id}/$fileName';
      await supabase.storage.from('Lavendera_QRIS').upload(path, _imageFile!);
      final publicUrl = supabase.storage
          .from('Lavendera_QRIS')
          .getPublicUrl(path);
      if (mounted) setState(() => _imageUrl = publicUrl);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal upload: $e')));
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    context.read<OutletPaymentMethodActionBloc>().add(
      UpdateOutletPaymentMethodActionRequest(
        outletId: widget.outlet.id,
        paymentMethodId: widget.paymentMethod.id,
        body: {
          "type": _type,
          "provider_name": _providerNameController.text.trim(),
          "account_number": _type == 'bank_transfer'
              ? _accountNumberController.text.trim()
              : null,
          "account_name": _accountNameController.text.trim(),
          "qr_image_url": _type == 'qris' ? _imageUrl : null,
          "is_active": _isActive,
        },
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Metode Pembayaran'),
        content: const Text(
          'Anda yakin ingin menghapus metode pembayaran ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await _deleteQrisImage();
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal menghapus gambar QRIS: $e')),
                );
                return;
              }
              if (!mounted) return;
              context.read<OutletPaymentMethodActionBloc>().add(
                DeleteOutletPaymentMethodActionRequest(
                  outletId: widget.outlet.id,
                  paymentMethodId: widget.paymentMethod.id,
                ),
              );
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteQrisImage() async {
    final imageUrl = (_imageUrl?.isNotEmpty == true)
        ? _imageUrl
        : widget.paymentMethod.qrImageUrl;

    if (imageUrl == null || imageUrl.isEmpty) {
      debugPrint('QRIS: URL gambar kosong.');
      return;
    }

    const bucketName = 'Lavendera_QRIS';

    try {
      final uri = Uri.parse(imageUrl);
      final segments = uri.pathSegments;
      final bucketIndex = segments.indexOf(bucketName);

      if (bucketIndex == -1 || bucketIndex + 1 >= segments.length) {
        throw Exception('URL QRIS tidak valid: $imageUrl');
      }

      final storagePath = segments.skip(bucketIndex + 1).join('/');
      final slashIndex = storagePath.lastIndexOf('/');
      final folderPath = slashIndex == -1
          ? ''
          : storagePath.substring(0, slashIndex);
      final fileName = storagePath.substring(slashIndex + 1);

      final storage = Supabase.instance.client.storage.from(bucketName);

      debugPrint('QRIS target path: $storagePath');

      // Periksa objek sebelum penghapusan.
      final before = await storage.list(path: folderPath);
      final existsBefore = before.any((f) => f.name == fileName);

      debugPrint('QRIS exists before delete: $existsBefore');
      debugPrint(
        'QRIS folder contents before: ${before.map((f) => f.name).toList()}',
      );

      // Hapus objek.
      final removed = await storage.remove([storagePath]);
      debugPrint('QRIS remove response: $removed');

      // Periksa ulang objek setelah penghapusan.
      final after = await storage.list(path: folderPath);
      final existsAfter = after.any((f) => f.name == fileName);

      debugPrint('QRIS exists after delete: $existsAfter');
      debugPrint(
        'QRIS folder contents after: ${after.map((f) => f.name).toList()}',
      );

      if (existsAfter) {
        throw Exception('Objek masih terdaftar setelah request penghapusan.');
      }

      debugPrint('QRIS: Objek tidak ditemukan setelah penghapusan.');
    } catch (e, stackTrace) {
      debugPrint('QRIS delete error: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Detail Metode',
          style: AppTextStyles.headlineMedium.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: _showDeleteDialog,
          ),
        ],
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
                    dismissDirection: DismissDirection.horizontal,
                  ),
                );
              } else if (state is OutletPaymentMethodActionError) {
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
            child:
                BlocBuilder<
                  OutletPaymentMethodActionBloc,
                  OutletPaymentMethodActionState
                >(
                  builder: (context, state) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: PaymentMethodForm(
                        formKey: _formKey,
                        type: _type,
                        providerNameController: _providerNameController,
                        accountNumberController: _accountNumberController,
                        accountNameController: _accountNameController,
                        isActive: _isActive,
                        isLoading: state is OutletPaymentMethodActionLoading,
                        imageUrl: _imageUrl,
                        isUploading: _isUploading,
                        isEdit: true,
                        onTypeChanged: (val) => setState(() => _type = val),
                        onStatusChanged: (val) =>
                            setState(() => _isActive = val),
                        onPickImage: _pickImage,
                        onSave: _save,
                      ),
                    );
                  },
                ),
          ),
    );
  }
}
