import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lavendera/config/typography/app_text_styles.dart';
import 'package:lavendera/features/outlet/domain/entities/outlet.dart';
import 'package:lavendera/features/outlet_payment_method/presentation/bloc/action/outlet_payment_method_action_bloc.dart';
import 'package:lavendera/features/outlet_payment_method/presentation/bloc/outlet_payment_method_bloc.dart';
import 'package:lavendera/features/outlet_payment_method/presentation/pages/widgets/payment_method_form.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddOutletPaymentMethodPage extends StatefulWidget {
  final Outlet outlet;
  const AddOutletPaymentMethodPage({super.key, required this.outlet});

  @override
  State<AddOutletPaymentMethodPage> createState() =>
      _AddOutletPaymentMethodPageState();
}

class _AddOutletPaymentMethodPageState
    extends State<AddOutletPaymentMethodPage> {
  final _formKey = GlobalKey<FormState>();
  String _type = 'bank_transfer';
  final _providerNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _accountNameController = TextEditingController();
  bool _isActive = true;
  File? _imageFile;
  String? _imageUrl;
  bool _isUploading = false;

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
      CreateOutletPaymentMethodActionRequest(
        outletId: widget.outlet.id,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Tambah Metode',
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
                        isEdit: false,
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
