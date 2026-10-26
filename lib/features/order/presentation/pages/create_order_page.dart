import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lavendera/config/typography/app_text_styles.dart';
import 'package:lavendera/core/di/injection.dart';
import 'package:lavendera/core/utils/currency_formatter.dart';
import 'package:lavendera/features/customer/domain/entities/customer.dart';
import 'package:lavendera/features/customer/domain/usecases/get_customers_usecase.dart';
import 'package:lavendera/features/discount/domain/entities/discount.dart';
import 'package:lavendera/features/discount/domain/usecases/get_discounts_usecase.dart';
import 'package:lavendera/features/order/presentation/bloc/action/order_action_bloc.dart';
import 'package:lavendera/features/outlet/domain/entities/outlet.dart';
import 'package:lavendera/features/outlet/domain/usecases/get_outlets_usecase.dart';
import 'package:lavendera/features/service/domain/entities/service_item.dart';
import 'package:lavendera/features/service/domain/usecases/get_services_usecase.dart';

class OrderCartItem {
  final LaundryService service;
  num quantity;

  OrderCartItem({required this.service, required this.quantity});

  num get subtotal => service.price * quantity;
}

class CreateOrderPage extends StatefulWidget {
  const CreateOrderPage({super.key});

  @override
  State<CreateOrderPage> createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends State<CreateOrderPage> {
  // Master data
  List<Outlet> _outlets = [];
  List<Customer> _customers = [];
  List<LaundryService> _services = [];
  List<Discount> _discounts = [];
  bool _isLoadingInitialData = true;

  // Selected values
  Outlet? _selectedOutlet;
  Customer? _selectedCustomer;
  Discount? _selectedDiscount;
  String _paymentMethod = 'cash'; // cash, bank_transfer, qris

  // Cart
  final List<OrderCartItem> _cartItems = [];

  // Controllers
  final _paidAmountController = TextEditingController();
  final _notesController = TextEditingController();
  int _paidAmount = 0;

  @override
  void initState() {
    super.initState();
    _loadAllInitialData();
  }

  @override
  void dispose() {
    _paidAmountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadAllInitialData() async {
    try {
      final results = await Future.wait([
        sl<GetOutletsUsecase>().call(limit: 100),
        sl<GetCustomersUsecase>().call(limit: 100),
        sl<GetServicesUsecase>().call(limit: 100),
        sl<GetDiscountsUsecase>().call(limit: 100),
      ]);

      final outletsRes = results[0].data as List<Outlet>;
      final customersRes = results[1].data as List<Customer>;
      final servicesRes = results[2].data as List<LaundryService>;
      final discountsRes = results[3].data as List<Discount>;

      if (mounted) {
        setState(() {
          _outlets = outletsRes.where((o) => o.isActive).toList();
          if (_outlets.isNotEmpty) {
            _selectedOutlet = _outlets.first;
          }
          _customers = customersRes;
          _services = servicesRes.where((s) => s.isActive).toList();
          _discounts = discountsRes.where((d) => d.isActive).toList();
          _isLoadingInitialData = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingInitialData = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Gagal memuat master data. Silakan muat ulang.',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  // Calculations
  num get _subtotal {
    num total = 0;
    for (var item in _cartItems) {
      total += item.subtotal;
    }
    return total;
  }

  num get _discountAmount {
    if (_selectedDiscount == null) return 0;
    if (_selectedDiscount!.type.toLowerCase() == 'percentage') {
      return (_subtotal * (_selectedDiscount!.value / 100)).round();
    } else {
      return _selectedDiscount!.value > _subtotal
          ? _subtotal
          : _selectedDiscount!.value;
    }
  }

  num get _totalAmount {
    final total = _subtotal - _discountAmount;
    return total > 0 ? total : 0;
  }

  int get _changeAmount {
    if (_paymentMethod != 'cash') return 0;

    final change = _paidAmount - _totalAmount;
    return change > 0 ? change.toInt() : 0;
  }

  void _syncPaidAmountWithTotal() {
    if (_paymentMethod == 'cash') {
      _paidAmount = _totalAmount.toInt();
      _paidAmountController.text = CurrencyFormatter.formatNumber(_totalAmount);
    }
  }

  void _addServiceToCart(LaundryService service) {
    final existingIdx = _cartItems.indexWhere(
      (element) => element.service.id == service.id,
    );
    setState(() {
      if (existingIdx >= 0) {
        _cartItems[existingIdx].quantity += 1;
      } else {
        _cartItems.add(
          OrderCartItem(
            service: service,
            quantity: service.minQuantity > 0 ? service.minQuantity : 1,
          ),
        );
      }
      _syncPaidAmountWithTotal();
    });
  }

  void _updateCartItemQuantity(int index, num delta) {
    setState(() {
      final item = _cartItems[index];
      final newQty = item.quantity + delta;
      if (newQty <= 0) {
        _cartItems.removeAt(index);
      } else {
        item.quantity = newQty;
      }
      _syncPaidAmountWithTotal();
    });
  }

  void _showAddServiceBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Pilih Layanan Laundry',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _services.isEmpty
                        ? const Center(
                            child: Text(
                              'Belum ada layanan tersedia',
                              style: TextStyle(fontFamily: 'Poppins'),
                            ),
                          )
                        : ListView.separated(
                            controller: scrollController,
                            itemCount: _services.length,
                            separatorBuilder: (_, _) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final service = _services[index];
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4A99AD)
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.local_laundry_service_rounded,
                                    color: Color(0xFF4A99AD),
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  service.name,
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13.5,
                                  ),
                                ),
                                subtitle: Text(
                                  '${CurrencyFormatter.format(service.price)} / ${service.unit} • ${service.durationDays} hari',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                trailing: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    _addServiceToCart(service);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4A99AD),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 6,
                                    ),
                                  ),
                                  child: const Text(
                                    '+ Pilih',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showCustomerPickerBottomSheet() {
    final searchCtrl = TextEditingController();
    List<Customer> filtered = List.from(_customers);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Pilih Pelanggan',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: searchCtrl,
                      decoration: InputDecoration(
                        hintText: 'Cari nama atau telepon pelanggan...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        filled: true,
                        fillColor: const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                        ),
                      ),
                      onChanged: (val) {
                        setModalState(() {
                          final q = val.toLowerCase().trim();
                          filtered = _customers.where((c) {
                            return c.name.toLowerCase().contains(q) ||
                                c.phone.toLowerCase().contains(q);
                          }).toList();
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: filtered.isEmpty
                          ? const Center(
                              child: Text(
                                'Pelanggan tidak ditemukan',
                                style: TextStyle(fontFamily: 'Poppins'),
                              ),
                            )
                          : ListView.separated(
                              itemCount: filtered.length,
                              separatorBuilder: (_, _) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final cust = filtered[index];
                                final isSelected =
                                    _selectedCustomer?.id == cust.id;
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: CircleAvatar(
                                    backgroundColor: const Color(0xFF4A99AD)
                                        .withValues(alpha: 0.1),
                                    child: Text(
                                      cust.name.isNotEmpty
                                          ? cust.name[0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                        color: Color(0xFF4A99AD),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    cust.name,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w600,
                                      color: isSelected
                                          ? const Color(0xFF4A99AD)
                                          : const Color(0xFF0F172A),
                                    ),
                                  ),
                                  subtitle: Text(
                                    cust.phone,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  trailing: isSelected
                                      ? const Icon(
                                          Icons.check_circle_rounded,
                                          color: Color(0xFF4A99AD),
                                        )
                                      : null,
                                  onTap: () {
                                    setState(() {
                                      _selectedCustomer = cust;
                                    });
                                    Navigator.pop(ctx);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _submitOrder() {
    if (_selectedOutlet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Silakan pilih outlet terlebih dahulu',
            style: TextStyle(fontFamily: 'Poppins'),
          ),
          backgroundColor: Color(0xFFDC2626),
          dismissDirection: DismissDirection.horizontal,
        ),
      );
      return;
    }

    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Silakan pilih pelanggan terlebih dahulu',
            style: TextStyle(fontFamily: 'Poppins'),
          ),
          backgroundColor: Color(0xFFDC2626),
          dismissDirection: DismissDirection.horizontal,
        ),
      );
      return;
    }

    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Silakan tambahkan minimal 1 layanan laundry',
            style: TextStyle(fontFamily: 'Poppins'),
          ),
          backgroundColor: Color(0xFFDC2626),
          dismissDirection: DismissDirection.horizontal,
        ),
      );
      return;
    }

    // Build Request Body according to documentation
    final body = <String, dynamic>{
      'outlet_id': _selectedOutlet!.id,
      'customer_id': _selectedCustomer!.id,
      'payment_method': _paymentMethod,
      'items': _cartItems.map((item) {
        return {'service_id': item.service.id, 'quantity': item.quantity};
      }).toList(),
    };

    if (_selectedDiscount != null) {
      body['discount_id'] = _selectedDiscount!.id;
    }

    if (_paymentMethod == 'cash') {
      body['paid_amount'] = _paidAmount;
    }

    final notes = _notesController.text.trim();
    if (notes.isNotEmpty) {
      body['notes'] = notes;
    }
    debugPrint("HASIL DATA:$body");
    context.read<OrderActionBloc>().add(CreateOrderActionRequest(body: body));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderActionBloc, OrderActionState>(
      listener: (context, state) {
        if (state is OrderActionSuccess) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text(
            'Order Kasir Baru',
            style: AppTextStyles.headlineMedium.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: _isLoadingInitialData
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF4A99AD)),
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // 1. Outlet Selector
                  _buildSectionCard(
                    title: 'Outlet Cabang',
                    icon: Icons.store_rounded,
                    child: DropdownButtonFormField<Outlet>(
                      initialValue: _selectedOutlet,
                      isExpanded: true,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: _outlets.map((outlet) {
                        return DropdownMenuItem<Outlet>(
                          value: outlet,
                          child: Text(
                            outlet.name,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13.5,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedOutlet = val;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 2. Customer Selector
                  _buildSectionCard(
                    title: 'Pelanggan',
                    icon: Icons.person_rounded,
                    child: InkWell(
                      onTap: _showCustomerPickerBottomSheet,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4A99AD)
                                    .withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person_search_rounded,
                                color: Color(0xFF4A99AD),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _selectedCustomer != null
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _selectedCustomer!.name,
                                          style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13.5,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                        Text(
                                          _selectedCustomer!.phone,
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 11.5,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Text(
                                      'Pilih data pelanggan...',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 13,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: Color(0xFF94A3B8),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 3. Cart Items
                  _buildSectionCard(
                    title: 'Daftar Layanan Laundry',
                    icon: Icons.local_laundry_service_rounded,
                    action: TextButton.icon(
                      onPressed: _showAddServiceBottomSheet,
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: const Text(
                        'Tambah',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF4A99AD),
                      ),
                    ),
                    child: _cartItems.isEmpty
                        ? Container(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            alignment: Alignment.center,
                            child: Column(
                              children: [
                                Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 32,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Belum ada layanan yang dipilih',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _cartItems.length,
                            separatorBuilder: (_, _) =>
                                const Divider(height: 16),
                            itemBuilder: (context, index) {
                              final item = _cartItems[index];
                              return Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.service.name,
                                          style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                        Text(
                                          '${CurrencyFormatter.format(item.service.price)} / ${item.service.unit}',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 11.5,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.remove_circle_outline_rounded,
                                          size: 20,
                                          color: Color(0xFFDC2626),
                                        ),
                                        onPressed: () =>
                                            _updateCartItemQuantity(index, -1),
                                      ),
                                      Text(
                                        '${item.quantity}',
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13.5,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.add_circle_outline_rounded,
                                          size: 20,
                                          color: Color(0xFF4A99AD),
                                        ),
                                        onPressed: () =>
                                            _updateCartItemQuantity(index, 1),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: 75,
                                    child: Text(
                                      CurrencyFormatter.format(item.subtotal),
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        color: Color(0xFF0F172A),
                                      ),
                                      textAlign: TextAlign.end,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 14),

                  // 4. Discount Selector (Optional)
                  _buildSectionCard(
                    title: 'Diskon & Promo (Opsional)',
                    icon: Icons.percent_rounded,
                    child: DropdownButtonFormField<Discount?>(
                      initialValue: _selectedDiscount,
                      isExpanded: true,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: [
                        const DropdownMenuItem<Discount?>(
                          value: null,
                          child: Text(
                            'Tanpa Diskon',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                        ..._discounts.map((discount) {
                          final valueText =
                              discount.type.toLowerCase() == 'percentage'
                              ? '${discount.value}%'
                              : CurrencyFormatter.format(discount.value);
                          return DropdownMenuItem<Discount?>(
                            value: discount,
                            child: Text(
                              '${discount.name} ($valueText)',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                              ),
                            ),
                          );
                        }),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _selectedDiscount = val;
                          _syncPaidAmountWithTotal();
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 5. Initial Status & Notes
                  _buildSectionCard(
                    title: 'Catatan (Opsional)',
                    icon: Icons.note_alt_rounded,
                    child: TextField(
                      controller: _notesController,
                      maxLines: 2,
                      maxLength: 1000,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Contoh: Tolong pakai pewangi lavender...',
                        hintStyle: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Colors.grey.shade400,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 6. Payment Method & Cash Calculator
                  _buildSectionCard(
                    title: 'Metode Pembayaran',
                    icon: Icons.payment_rounded,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _buildPaymentMethodOption(
                              label: 'Tunai',
                              method: 'cash',
                              icon: Icons.payments_rounded,
                            ),
                            const SizedBox(width: 8),
                            _buildPaymentMethodOption(
                              label: 'Transfer',
                              method: 'bank_transfer',
                              icon: Icons.account_balance_rounded,
                            ),
                            const SizedBox(width: 8),
                            _buildPaymentMethodOption(
                              label: 'QRIS',
                              method: 'qris',
                              icon: Icons.qr_code_2_rounded,
                            ),
                          ],
                        ),
                        if (_paymentMethod == 'cash') ...[
                          const SizedBox(height: 16),
                          const Text(
                            'Nominal Uang Diterima',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF475569),
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _paidAmountController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [CurrencyInputFormatter()],
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                            decoration: InputDecoration(
                              prefixText: 'Rp ',
                              prefixStyle: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF4A99AD),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF1F5F9),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                            ),
                            onChanged: (val) {
                              final clean = val.replaceAll(
                                RegExp(r'[^0-9]'),
                                '',
                              );
                              setState(() {
                                _paidAmount = int.tryParse(clean) ?? 0;
                              });
                            },
                          ),
                          const SizedBox(height: 8),
                          // Kembalian info
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _changeAmount >= 0
                                  ? const Color(0xFFF0FDF4)
                                  : const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Kembalian:',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  CurrencyFormatter.format(_changeAmount),
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: _changeAmount >= 0
                                        ? const Color(0xFF16A34A)
                                        : const Color(0xFFDC2626),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 90),
                ],
              ),
        bottomSheet: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                offset: const Offset(0, -4),
                blurRadius: 10,
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Tagihan',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(_totalAmount),
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: BlocBuilder<OrderActionBloc, OrderActionState>(
                    builder: (context, state) {
                      final isLoading = state is OrderActionLoading;
                      return ElevatedButton(
                        onPressed: isLoading ? null : _submitOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A99AD),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Buat Pesanan',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    Widget? action,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: const Color(0xFF4A99AD)),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              ?action,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildPaymentMethodOption({
    required String label,
    required String method,
    required IconData icon,
  }) {
    final isSelected = _paymentMethod == method;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          setState(() {
            _paymentMethod = method;
            _syncPaidAmountWithTotal();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF4A99AD).withValues(alpha: 0.1)
                : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? const Color(0xFF4A99AD) : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? const Color(0xFF4A99AD)
                    : const Color(0xFF64748B),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? const Color(0xFF4A99AD)
                      : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
