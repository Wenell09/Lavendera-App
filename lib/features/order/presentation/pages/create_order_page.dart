import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lavendera/config/typography/app_text_styles.dart';
import 'package:lavendera/core/utils/currency_formatter.dart';
import 'package:lavendera/features/customer/domain/entities/customer.dart';
import 'package:lavendera/features/customer/presentation/bloc/customer_bloc.dart';
import 'package:lavendera/features/discount/domain/entities/discount.dart';
import 'package:lavendera/features/discount/presentation/bloc/discount_bloc.dart';
import 'package:lavendera/features/order/presentation/bloc/action/order_action_bloc.dart';
import 'package:lavendera/features/order/presentation/bloc/order_bloc.dart';
import 'package:lavendera/features/order/presentation/widgets/order_cart_item.dart';
import 'package:lavendera/features/outlet/domain/entities/outlet.dart';
import 'package:lavendera/features/outlet/presentation/bloc/outlet_bloc.dart';
import 'package:lavendera/features/outlet_payment_method/domain/entities/outlet_payment_method.dart';
import 'package:lavendera/features/outlet_payment_method/presentation/bloc/outlet_payment_method_bloc.dart';
import 'package:lavendera/features/outlet_user/presentation/bloc/user_outlet/user_outlet_bloc.dart';
import 'package:lavendera/features/profile/presentation/bloc/profile_detail_bloc.dart';
import 'package:lavendera/features/service/domain/entities/service_item.dart';
import 'package:lavendera/features/service/presentation/bloc/service_bloc.dart';

class CreateOrderPage extends StatefulWidget {
  const CreateOrderPage({super.key});

  @override
  State<CreateOrderPage> createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends State<CreateOrderPage> {
  List<Outlet> _outlets = [];
  List<Customer> _customers = [];
  List<LaundryService> _services = [];
  List<Discount> _discounts = [];
  List<OutletPaymentMethod> _outletPaymentMethods = [];
  Outlet? _selectedOutlet;
  Customer? _selectedCustomer;
  Discount? _selectedDiscount;
  String _paymentMethod = 'cash';
  final List<OrderCartItem> _cartItems = [];
  final _paidAmountController = TextEditingController();
  final _notesController = TextEditingController();
  final _serviceSearchController = TextEditingController();
  int _paidAmount = 0;

  bool _isOutletLoaded = false;
  bool _isCustomerLoaded = false;
  bool _isServiceLoaded = false;
  bool _isDiscountLoaded = false;

  bool get _isLoadingInitialData =>
      !_isOutletLoaded ||
      !_isCustomerLoaded ||
      !_isServiceLoaded ||
      !_isDiscountLoaded;

  @override
  void dispose() {
    _paidAmountController.dispose();
    _notesController.dispose();
    _serviceSearchController.dispose();
    super.dispose();
  }

  void _loadAllInitialData(String role, String userId) {
    if (role.toUpperCase() == 'ADMIN') {
      context.read<OutletBloc>().add(GetOutletsRequest(limit: 100));
    } else {
      context.read<UserOutletBloc>().add(GetUserOutletRequest(userId: userId));
    }
    context.read<CustomerBloc>().add(GetCustomersRequest(limit: 100));
    context.read<ServiceBloc>().add(GetServicesRequest(limit: 100));
    context.read<DiscountBloc>().add(GetDiscountsRequest(limit: 100));
  }

  void _fetchPaymentMethods() {
    if (_selectedOutlet != null) {
      context.read<OutletPaymentMethodBloc>().add(
        GetOutletPaymentMethodsRequest(outletId: _selectedOutlet!.id),
      );
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark
          ? colorScheme.surfaceContainerHigh
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredServices = _services.where((s) {
              return s.name.toLowerCase().contains(
                _serviceSearchController.text.toLowerCase(),
              );
            }).toList();

            return DraggableScrollableSheet(
              initialChildSize: 0.8,
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
                            color: colorScheme.outlineVariant,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Pilih Layanan Laundry',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _serviceSearchController,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: colorScheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Cari layanan...',
                          hintStyle: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                          suffixIcon: _serviceSearchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    size: 18,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  onPressed: () {
                                    setModalState(() {
                                      _serviceSearchController.clear();
                                    });
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: isDark
                              ? colorScheme.surfaceContainerHighest.withValues(
                                  alpha: 0.3,
                                )
                              : colorScheme.surfaceContainerLowest,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: colorScheme.outlineVariant.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: colorScheme.outlineVariant.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                        ),
                        onChanged: (val) => setModalState(() {}),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: filteredServices.isEmpty
                            ? Center(
                                child: Text(
                                  'Layanan tidak ditemukan',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              )
                            : ListView.separated(
                                controller: scrollController,
                                itemCount: filteredServices.length,
                                separatorBuilder: (_, _) => Divider(
                                  height: 1,
                                  color: colorScheme.outlineVariant.withValues(
                                    alpha: 0.4,
                                  ),
                                ),
                                itemBuilder: (context, index) {
                                  final service = filteredServices[index];
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: colorScheme.primary.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        Icons.local_laundry_service_rounded,
                                        color: colorScheme.primary,
                                        size: 20,
                                      ),
                                    ),
                                    title: Text(
                                      service.name,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13.5,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '${CurrencyFormatter.format(service.price)} / ${service.unit} • ${service.durationDays} hari',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    trailing: ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(ctx);
                                        _addServiceToCart(service);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: colorScheme.primary,
                                        foregroundColor: colorScheme.onPrimary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 6,
                                        ),
                                      ),
                                      child: Text(
                                        '+ Pilih',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          color: colorScheme.onPrimary,
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
      },
    );
  }

  void _showCustomerPickerBottomSheet() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final searchCtrl = TextEditingController();
    List<Customer> filtered = List.from(_customers);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark
          ? colorScheme.surfaceContainerHigh
          : Colors.white,
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
                          color: colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Pilih Pelanggan',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: searchCtrl,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Cari nama atau telepon pelanggan...',
                        hintStyle: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        filled: true,
                        fillColor: isDark
                            ? colorScheme.surfaceContainerHighest.withValues(
                                alpha: 0.3,
                              )
                            : colorScheme.surfaceContainerLowest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: colorScheme.outlineVariant.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: colorScheme.outlineVariant.withValues(
                              alpha: 0.3,
                            ),
                          ),
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
                          ? Center(
                              child: Text(
                                'Pelanggan tidak ditemukan',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            )
                          : ListView.separated(
                              itemCount: filtered.length,
                              separatorBuilder: (_, _) => Divider(
                                height: 1,
                                color: colorScheme.outlineVariant.withValues(
                                  alpha: 0.4,
                                ),
                              ),
                              itemBuilder: (context, index) {
                                final cust = filtered[index];
                                final isSelected =
                                    _selectedCustomer?.id == cust.id;
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: CircleAvatar(
                                    backgroundColor: colorScheme.primary
                                        .withValues(alpha: 0.1),
                                    child: Text(
                                      cust.name.isNotEmpty
                                          ? cust.name[0].toUpperCase()
                                          : '?',
                                      style: TextStyle(
                                        color: colorScheme.primary,
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
                                          ? colorScheme.primary
                                          : colorScheme.onSurface,
                                    ),
                                  ),
                                  subtitle: Text(
                                    cust.phone,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  trailing: isSelected
                                      ? Icon(
                                          Icons.check_circle_rounded,
                                          color: colorScheme.primary,
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
    final colorScheme = Theme.of(context).colorScheme;
    if (_selectedOutlet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Silakan pilih outlet terlebih dahulu',
            style: TextStyle(fontFamily: 'Poppins'),
          ),
          backgroundColor: colorScheme.error,
          dismissDirection: DismissDirection.horizontal,
        ),
      );
      return;
    }

    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Silakan pilih pelanggan terlebih dahulu',
            style: TextStyle(fontFamily: 'Poppins'),
          ),
          backgroundColor: colorScheme.error,
          dismissDirection: DismissDirection.horizontal,
        ),
      );
      return;
    }

    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Silakan tambahkan minimal 1 layanan laundry',
            style: TextStyle(fontFamily: 'Poppins'),
          ),
          backgroundColor: colorScheme.error,
          dismissDirection: DismissDirection.horizontal,
        ),
      );
      return;
    }

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
    context.read<OrderActionBloc>().add(CreateOrderActionRequest(body: body));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return MultiBlocListener(
      listeners: [
        BlocListener<OrderActionBloc, OrderActionState>(
          listener: (context, state) {
            if (state is OrderActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.message,
                    style: const TextStyle(fontFamily: 'Poppins'),
                  ),
                  backgroundColor: const Color(0xFF10B981),
                  behavior: SnackBarBehavior.floating,
                  dismissDirection: DismissDirection.horizontal,
                ),
              );
              context.read<OrderBloc>().add(GetOrdersRequest());
            }
          },
        ),
        BlocListener<ProfileDetailBloc, ProfileDetailState>(
          listener: (context, state) {
            if (state is ProfileDetailLoaded) {
              _loadAllInitialData(state.profile.role, state.profile.id);
            }
          },
        ),
        BlocListener<OutletBloc, OutletState>(
          listener: (context, state) {
            if (state is OutletLoaded) {
              setState(() {
                final Map<String, Outlet> uniqueOutlets = {};
                for (var o in state.outlets.where((o) => o.isActive)) {
                  uniqueOutlets[o.id] = o;
                }
                _outlets = uniqueOutlets.values.toList();
                if (_selectedOutlet == null && _outlets.isNotEmpty) {
                  _selectedOutlet = _outlets.first;
                } else if (_selectedOutlet != null) {
                  final matched = _outlets.where(
                    (o) => o.id == _selectedOutlet!.id,
                  );
                  _selectedOutlet = matched.isNotEmpty
                      ? matched.first
                      : (_outlets.isNotEmpty ? _outlets.first : null);
                }
                _isOutletLoaded = true;
              });
              _fetchPaymentMethods();
            } else if (state is OutletError) {
              setState(() => _isOutletLoaded = true);
            }
          },
        ),
        BlocListener<UserOutletBloc, UserOutletState>(
          listener: (context, state) {
            if (state is UserOutletLoaded) {
              setState(() {
                final summary = state.userOutlet.outlet;
                final outlet = Outlet(
                  id: summary.id,
                  name: summary.name,
                  slug: summary.slug,
                  phone: '',
                  address: '',
                  isPublicOrderEnabled: true,
                  isActive: true,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );
                _outlets = [outlet];
                _selectedOutlet ??= outlet;
                _isOutletLoaded = true;
              });
              _fetchPaymentMethods();
            } else if (state is UserOutletError) {
              setState(() => _isOutletLoaded = true);
            }
          },
        ),
        BlocListener<OutletPaymentMethodBloc, OutletPaymentMethodState>(
          listener: (context, state) {
            if (state is OutletPaymentMethodLoaded) {
              setState(() {
                _outletPaymentMethods = state.paymentMethods
                    .where((pm) => pm.isActive)
                    .toList();
              });
            }
          },
        ),
        BlocListener<CustomerBloc, CustomerState>(
          listener: (context, state) {
            if (state is CustomerLoaded) {
              setState(() {
                _customers = state.customers;
                _isCustomerLoaded = true;
              });
            } else if (state is CustomerError) {
              setState(() => _isCustomerLoaded = true);
            }
          },
        ),
        BlocListener<ServiceBloc, ServiceState>(
          listener: (context, state) {
            if (state is ServiceLoaded) {
              setState(() {
                _services = state.services.where((s) => s.isActive).toList();
                _isServiceLoaded = true;
              });
            } else if (state is ServiceError) {
              setState(() => _isServiceLoaded = true);
            }
          },
        ),
        BlocListener<DiscountBloc, DiscountState>(
          listener: (context, state) {
            if (state is DiscountLoaded) {
              setState(() {
                _discounts = state.discounts.where((d) => d.isActive).toList();
                _isDiscountLoaded = true;
              });
            } else if (state is DiscountError) {
              setState(() => _isDiscountLoaded = true);
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: Text(
            'Order Kasir Baru',
            style: AppTextStyles.headlineMedium.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Refresh Form',
              onPressed: () {
                final profileState = context.read<ProfileDetailBloc>().state;
                if (profileState is ProfileDetailLoaded) {
                  setState(() {
                    _isOutletLoaded = false;
                    _isCustomerLoaded = false;
                    _isServiceLoaded = false;
                    _isDiscountLoaded = false;
                  });
                  _loadAllInitialData(
                    profileState.profile.role,
                    profileState.profile.id,
                  );
                } else {
                  context.read<ProfileDetailBloc>().add(GetProfileRequest());
                }
              },
            ),
          ],
        ),
        body: _isLoadingInitialData
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: colorScheme.primary),
                    const SizedBox(height: 16),
                    Text(
                      'Memuat data...',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () {
                        final profileState = context
                            .read<ProfileDetailBloc>()
                            .state;
                        if (profileState is ProfileDetailLoaded) {
                          _loadAllInitialData(
                            profileState.profile.role,
                            profileState.profile.id,
                          );
                        } else {
                          context.read<ProfileDetailBloc>().add(
                            GetProfileRequest(),
                          );
                        }
                      },
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text(
                        'Refresh Sekarang',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // 1. Outlet Selector
                  _buildSectionCard(
                    title: 'Outlet Cabang',
                    icon: Icons.store_rounded,
                    child: DropdownButtonFormField<Outlet>(
                      key: ValueKey(_selectedOutlet?.id),
                      initialValue: _outlets.contains(_selectedOutlet)
                          ? _selectedOutlet
                          : (_outlets.isNotEmpty ? _outlets.first : null),
                      isExpanded: true,
                      dropdownColor: isDark
                          ? colorScheme.surfaceContainerHigh
                          : Colors.white,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        filled: true,
                        fillColor: isDark
                            ? colorScheme.surfaceContainerHighest.withValues(
                                alpha: 0.3,
                              )
                            : colorScheme.surfaceContainerLowest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: colorScheme.outlineVariant.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: colorScheme.outlineVariant.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                      ),
                      items: _outlets.map((outlet) {
                        return DropdownMenuItem<Outlet>(
                          value: outlet,
                          child: Text(
                            outlet.name,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13.5,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedOutlet = val;
                        });
                        _fetchPaymentMethods();
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
                          color: isDark
                              ? colorScheme.surfaceContainerHighest.withValues(
                                  alpha: 0.3,
                                )
                              : colorScheme.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: colorScheme.outlineVariant.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withValues(
                                  alpha: 0.15,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.person_search_rounded,
                                color: colorScheme.primary,
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
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13.5,
                                            color: colorScheme.onSurface,
                                          ),
                                        ),
                                        Text(
                                          _selectedCustomer!.phone,
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 11.5,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Text(
                                      'Pilih data pelanggan...',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 13,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: colorScheme.onSurfaceVariant,
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
                        foregroundColor: colorScheme.primary,
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
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Belum ada layanan yang dipilih',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _cartItems.length,
                            separatorBuilder: (_, _) => Divider(
                              height: 16,
                              color: colorScheme.outlineVariant.withValues(
                                alpha: 0.4,
                              ),
                            ),
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
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                            color: colorScheme.onSurface,
                                          ),
                                        ),
                                        Text(
                                          '${CurrencyFormatter.format(item.service.price)} / ${item.service.unit}',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 11.5,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.remove_circle_outline_rounded,
                                          size: 20,
                                          color: colorScheme.error,
                                        ),
                                        onPressed: () =>
                                            _updateCartItemQuantity(index, -1),
                                      ),
                                      Text(
                                        '${item.quantity}',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13.5,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.add_circle_outline_rounded,
                                          size: 20,
                                          color: colorScheme.primary,
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
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        color: colorScheme.onSurface,
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
                      key: ValueKey(_selectedDiscount?.id),
                      initialValue: _discounts.contains(_selectedDiscount)
                          ? _selectedDiscount
                          : null,
                      isExpanded: true,
                      dropdownColor: isDark
                          ? colorScheme.surfaceContainerHigh
                          : Colors.white,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        filled: true,
                        fillColor: isDark
                            ? colorScheme.surfaceContainerHighest.withValues(
                                alpha: 0.3,
                              )
                            : colorScheme.surfaceContainerLowest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: colorScheme.outlineVariant.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: colorScheme.outlineVariant.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                      ),
                      items: [
                        DropdownMenuItem<Discount?>(
                          value: null,
                          child: Text(
                            'Tanpa Diskon',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        ..._discounts.map((discount) {
                          final label =
                              discount.type.toLowerCase() == 'percentage'
                              ? '${discount.value}%'
                              : CurrencyFormatter.format(discount.value);
                          return DropdownMenuItem<Discount?>(
                            value: discount,
                            child: Text(
                              '${discount.name} ($label)',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                color: colorScheme.onSurface,
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
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Contoh: Tolong pakai pewangi lavender...',
                        hintStyle: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        filled: true,
                        fillColor: isDark
                            ? colorScheme.surfaceContainerHighest.withValues(
                                alpha: 0.3,
                              )
                            : colorScheme.surfaceContainerLowest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: colorScheme.outlineVariant.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: colorScheme.outlineVariant.withValues(
                              alpha: 0.3,
                            ),
                          ),
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
                          Text(
                            'Nominal Uang Diterima',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _paidAmountController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [CurrencyInputFormatter()],
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                            decoration: InputDecoration(
                              prefixText: 'Rp ',
                              prefixStyle: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w700,
                                color: colorScheme.primary,
                              ),
                              filled: true,
                              fillColor: isDark
                                  ? colorScheme.surfaceContainerHighest
                                        .withValues(alpha: 0.3)
                                  : colorScheme.surfaceContainerLowest,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: colorScheme.outlineVariant.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: colorScheme.outlineVariant.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
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
                                  ? (isDark
                                        ? const Color(0xFF064E3B).withValues(
                                            alpha: 0.3,
                                          )
                                        : const Color(0xFFF0FDF4))
                                  : (isDark
                                        ? const Color(0xFF7F1D1D).withValues(
                                            alpha: 0.3,
                                          )
                                        : const Color(0xFFFEF2F2)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Kembalian:',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                Text(
                                  CurrencyFormatter.format(_changeAmount),
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: _changeAmount >= 0
                                        ? (isDark
                                              ? const Color(0xFF34D399)
                                              : const Color(0xFF16A34A))
                                        : colorScheme.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          const SizedBox(height: 16),
                          Text(
                            'Informasi Pembayaran / Rekening Outlet',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 6),
                          BlocBuilder<
                            OutletPaymentMethodBloc,
                            OutletPaymentMethodState
                          >(
                            builder: (context, state) {
                              if (state is OutletPaymentMethodLoading) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: CircularProgressIndicator(
                                      color: colorScheme.primary,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                );
                              }
                              final filteredMethods = _outletPaymentMethods
                                  .where((pm) => pm.type == _paymentMethod)
                                  .toList();

                              if (filteredMethods.isEmpty) {
                                return Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? colorScheme.surfaceContainerHighest
                                              .withValues(alpha: 0.3)
                                        : colorScheme.surfaceContainerLowest,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Tidak ada detail pembayaran untuk metode ini.',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                );
                              }
                              return ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: filteredMethods.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final pm = filteredMethods[index];
                                  final accNum = pm.accountNumber;
                                  return Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? colorScheme.surfaceContainerHighest
                                                .withValues(alpha: 0.3)
                                          : colorScheme.surfaceContainerLowest,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: colorScheme.outlineVariant
                                            .withValues(
                                              alpha: isDark ? 0.2 : 0.5,
                                            ),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          accNum != null && accNum.isNotEmpty
                                              ? '${pm.providerName} - $accNum'
                                              : pm.providerName,
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                            color: colorScheme.onSurface,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Atas Nama: ${pm.accountName}',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 12,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        if (pm.qrImageUrl != null &&
                                            pm.qrImageUrl!.isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Image.network(
                                              pm.qrImageUrl!,
                                              height: 120,
                                              fit: BoxFit.contain,
                                              errorBuilder: (_, _, _) =>
                                                  const SizedBox(),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 200),
                ],
              ),
        bottomSheet: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: isDark ? colorScheme.surfaceContainer : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                offset: const Offset(0, -2),
                blurRadius: 10,
              ),
            ],
            border: Border(
              top: BorderSide(
                color: colorScheme.outlineVariant.withValues(
                  alpha: isDark ? 0.2 : 0.4,
                ),
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Subtotal',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(_subtotal),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                if (_discountAmount > 0) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Diskon',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: colorScheme.error,
                        ),
                      ),
                      Text(
                        '- ${CurrencyFormatter.format(_discountAmount)}',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ],
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Divider(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(_totalAmount),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: BlocBuilder<OrderActionBloc, OrderActionState>(
                    builder: (context, state) {
                      final isLoading = state is OrderActionLoading;
                      return ElevatedButton(
                        onPressed: isLoading ? null : _submitOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: colorScheme.onPrimary,
                                ),
                              )
                            : Text(
                                'Buat Pesanan',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onPrimary,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainer : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(
            alpha: isDark ? 0.2 : 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
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
                ? colorScheme.primary.withValues(alpha: 0.12)
                : (isDark
                      ? colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.3,
                        )
                      : colorScheme.surfaceContainerLowest),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.outlineVariant.withValues(
                      alpha: isDark ? 0.2 : 0.3,
                    ),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
