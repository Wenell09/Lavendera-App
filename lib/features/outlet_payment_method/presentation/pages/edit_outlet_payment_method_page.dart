import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lavendera/config/typography/app_text_styles.dart';
import 'package:lavendera/core/di/injection.dart';
import 'package:lavendera/features/outlet/domain/entities/outlet.dart';
import 'package:lavendera/features/outlet_payment_method/data/datasources/outlet_payment_method_remote_data_source.dart';
import 'package:lavendera/features/outlet_payment_method/domain/entities/outlet_payment_method.dart';
import 'package:lavendera/features/outlet_payment_method/presentation/bloc/action/outlet_payment_method_action_bloc.dart';
import 'package:lavendera/features/outlet_payment_method/presentation/bloc/outlet_payment_method_bloc.dart';
import 'package:lavendera/features/outlet_payment_method/presentation/pages/widgets/payment_method_form.dart';

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
      await sl<OutletPaymentMethodRemoteDataSource>().uploadQrisImage(
        widget.outlet.id,
        widget.paymentMethod.id,
        _imageFile!.path,
      );
      context.read<OutletPaymentMethodBloc>().add(
        GetOutletPaymentMethodsRequest(outletId: widget.outlet.id),
      );
      if (mounted) setState(() => _imageUrl = 'uploaded'); // trigger UI update
    } catch (e) {
      debugPrint('Error upload: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal upload: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            dismissDirection: DismissDirection.horizontal,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _handleDeleteImage() async {
    setState(() => _isUploading = true);
    try {
      await _deleteQrisImage();
      if (mounted) {
        setState(() {
          _imageFile = null;
          _imageUrl = null;
        });
        context.read<OutletPaymentMethodBloc>().add(
          GetOutletPaymentMethodsRequest(outletId: widget.outlet.id),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus gambar QRIS: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            dismissDirection: DismissDirection.horizontal,
          ),
        );
      }
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
                  SnackBar(
                    content: Text('Gagal menghapus gambar QRIS: $e'),
                    backgroundColor: Colors.redAccent,
                    behavior: SnackBarBehavior.floating,
                    dismissDirection: DismissDirection.horizontal,
                  ),
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
    try {
      await sl<OutletPaymentMethodRemoteDataSource>().deleteQrisImage(
        widget.outlet.id,
        widget.paymentMethod.id,
      );
    } catch (e) {
      debugPrint('Error delete QRIS: $e');
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
                        imageFile: _imageFile,
                        imageUrl: _imageUrl,
                        isUploading: _isUploading,
                        isEdit: true,
                        onTypeChanged: (val) => setState(() => _type = val),
                        onStatusChanged: (val) =>
                            setState(() => _isActive = val),
                        onPickImage: _pickImage,
                        onDeleteImage: _handleDeleteImage,
                        onSave: _save,
                      ),
                    );
                  },
                ),
          ),
    );
  }
}
