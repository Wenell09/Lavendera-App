import 'package:lavendera/features/order/domain/entities/order_entity.dart';
import 'package:lavendera/features/service/domain/entities/service_item.dart';

class OrderPaymentModel {
  final String id;
  final num amount;
  final String paymentMethod;
  final String status;
  final String? referenceNumber;
  final String? notes;
  final DateTime? paidAt;
  final DateTime? verifiedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  OrderPaymentModel({
    required this.id,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    this.referenceNumber,
    this.notes,
    this.paidAt,
    this.verifiedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderPaymentModel.fromJson(Map<String, dynamic> json) {
    return OrderPaymentModel(
      id: json['id']?.toString() ?? '',
      amount: json['amount'] ?? 0,
      paymentMethod: json['payment_method']?.toString() ?? 'cash',
      status: json['status']?.toString() ?? 'BELUM_BAYAR',
      referenceNumber: json['reference_number']?.toString(),
      notes: json['notes']?.toString(),
      paidAt: json['paid_at'] != null
          ? DateTime.tryParse(json['paid_at'].toString())
          : null,
      verifiedAt: json['verified_at'] != null
          ? DateTime.tryParse(json['verified_at'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())?.toLocal()
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())?.toLocal()
          : null,
    );
  }

  OrderPayment toEntity() {
    return OrderPayment(
      id: id,
      amount: amount,
      paymentMethod: paymentMethod,
      status: status,
      referenceNumber: referenceNumber,
      notes: notes,
      paidAt: paidAt,
      verifiedAt: verifiedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class OrderItemServiceModel {
  final String id;
  final String name;
  final num price;
  final int durationDays;
  final ServiceCategorySummary category;

  OrderItemServiceModel({
    required this.id,
    required this.name,
    required this.price,
    required this.durationDays,
    required this.category,
  });

  factory OrderItemServiceModel.fromJson(Map<String, dynamic> json) {
    final catJson = json['category'] is Map<String, dynamic>
        ? json['category']
        : <String, dynamic>{};
    return OrderItemServiceModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: json['price'] ?? 0,
      durationDays: json['duration_days'] ?? 1,
      category: ServiceCategorySummary.fromJson(catJson),
    );
  }

  OrderItemService toEntity() {
    return OrderItemService(
      id: id,
      name: name,
      price: price,
      durationDays: durationDays,
      category: category,
    );
  }
}

class OrderItemModel {
  final String id;
  final num price;
  final num quantity;
  final String unit;
  final num subtotal;
  final OrderItemServiceModel service;

  OrderItemModel({
    required this.id,
    required this.price,
    required this.quantity,
    required this.unit,
    required this.subtotal,
    required this.service,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    final srvJson = json['service'] is Map<String, dynamic>
        ? json['service']
        : <String, dynamic>{};
    return OrderItemModel(
      id: json['id']?.toString() ?? '',
      price: json['price'] ?? 0,
      quantity: json['quantity'] ?? 0,
      unit: json['unit']?.toString() ?? 'kg',
      subtotal: json['subtotal'] ?? 0,
      service: OrderItemServiceModel.fromJson(srvJson),
    );
  }

  OrderItem toEntity() {
    return OrderItem(
      id: id,
      price: price,
      quantity: quantity,
      unit: unit,
      subtotal: subtotal,
      service: service.toEntity(),
    );
  }
}

class OrderOutletModel {
  final String id;
  final String name;
  final String? phone;
  final String? address;

  OrderOutletModel({
    required this.id,
    required this.name,
    this.phone,
    this.address,
  });

  factory OrderOutletModel.fromJson(Map<String, dynamic> json) {
    return OrderOutletModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString(),
      address: json['address']?.toString(),
    );
  }

  OrderOutlet toEntity() {
    return OrderOutlet(id: id, name: name, phone: phone, address: address);
  }
}

class OrderCustomerModel {
  final String id;
  final String name;
  final String? phone;
  final String? address;

  OrderCustomerModel({
    required this.id,
    required this.name,
    this.phone,
    this.address,
  });

  factory OrderCustomerModel.fromJson(Map<String, dynamic> json) {
    return OrderCustomerModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString(),
      address: json['address']?.toString(),
    );
  }

  OrderCustomer toEntity() {
    return OrderCustomer(id: id, name: name, phone: phone, address: address);
  }
}

class OrderDiscountModel {
  final String id;
  final String name;
  final String type;
  final num value;

  OrderDiscountModel({
    required this.id,
    required this.name,
    required this.type,
    required this.value,
  });

  factory OrderDiscountModel.fromJson(Map<String, dynamic> json) {
    return OrderDiscountModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? 'percentage',
      value: json['value'] ?? 0,
    );
  }

  OrderDiscount toEntity() {
    return OrderDiscount(id: id, name: name, type: type, value: value);
  }
}

class OrderCreatorModel {
  final String id;
  final String name;

  OrderCreatorModel({required this.id, required this.name});

  factory OrderCreatorModel.fromJson(Map<String, dynamic> json) {
    return OrderCreatorModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  OrderCreator toEntity() {
    return OrderCreator(id: id, name: name);
  }
}

class OrderModel {
  final String id;
  final String? tenantId;
  final String orderNumber;
  final String? trackingToken;
  final String status;
  final String paymentStatus;
  final num subtotal;
  final num discountAmount;
  final num totalAmount;
  final num paidAmount;
  final num changeAmount;
  final OrderOutletModel outlet;
  final OrderCustomerModel customer;
  final OrderDiscountModel? discount;
  final OrderCreatorModel? creator;
  final List<OrderItemModel> items;
  final OrderPaymentModel? payment;
  final String? notes;
  final DateTime? estimatedDone;
  final DateTime? completedAt;
  final DateTime? canceledAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderModel({
    required this.id,
    this.tenantId,
    required this.orderNumber,
    this.trackingToken,
    required this.status,
    required this.paymentStatus,
    required this.subtotal,
    required this.discountAmount,
    required this.totalAmount,
    required this.paidAmount,
    required this.changeAmount,
    required this.outlet,
    required this.customer,
    this.discount,
    this.creator,
    required this.items,
    this.payment,
    this.notes,
    this.estimatedDone,
    this.completedAt,
    this.canceledAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List<dynamic>?) ?? [];
    return OrderModel(
      id: json['id']?.toString() ?? '',
      tenantId: json['tenant_id']?.toString(),
      orderNumber: json['order_number']?.toString() ?? '',
      trackingToken: json['tracking_token']?.toString(),
      status: json['status']?.toString() ?? 'MENUNGGU_KONFIRMASI',
      paymentStatus: json['payment_status']?.toString() ?? 'BELUM_BAYAR',
      subtotal: json['subtotal'] ?? 0,
      discountAmount: json['discount_amount'] ?? 0,
      totalAmount: json['total_amount'] ?? 0,
      paidAmount: json['paid_amount'] ?? 0,
      changeAmount: json['change_amount'] ?? 0,
      outlet: OrderOutletModel.fromJson(
        json['outlet'] is Map<String, dynamic>
            ? json['outlet']
            : <String, dynamic>{},
      ),
      customer: OrderCustomerModel.fromJson(
        json['customer'] is Map<String, dynamic>
            ? json['customer']
            : <String, dynamic>{},
      ),
      discount:
          json['discount'] != null && json['discount'] is Map<String, dynamic>
          ? OrderDiscountModel.fromJson(json['discount'])
          : null,
      creator:
          json['creator'] != null && json['creator'] is Map<String, dynamic>
          ? OrderCreatorModel.fromJson(json['creator'])
          : null,
      items: itemsList
          .whereType<Map<String, dynamic>>()
          .map((item) => OrderItemModel.fromJson(item))
          .toList(),
      payment:
          json['payment'] != null && json['payment'] is Map<String, dynamic>
          ? OrderPaymentModel.fromJson(json['payment'])
          : null,
      notes: json['notes']?.toString(),
      estimatedDone: json['estimated_done'] != null
          ? DateTime.tryParse(json['estimated_done'].toString())?.toLocal()
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'].toString())?.toLocal()
          : null,
      canceledAt: json['canceled_at'] != null
          ? DateTime.tryParse(json['canceled_at'].toString())?.toLocal()
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())?.toLocal() ??
                DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())?.toLocal() ??
                DateTime.now()
          : DateTime.now(),
    );
  }

  OrderEntity toEntity() {
    return OrderEntity(
      id: id,
      tenantId: tenantId,
      orderNumber: orderNumber,
      trackingToken: trackingToken,
      status: status,
      paymentStatus: paymentStatus,
      subtotal: subtotal,
      discountAmount: discountAmount,
      totalAmount: totalAmount,
      paidAmount: paidAmount,
      changeAmount: changeAmount,
      outlet: outlet.toEntity(),
      customer: customer.toEntity(),
      discount: discount?.toEntity(),
      creator: creator?.toEntity(),
      items: items.map((e) => e.toEntity()).toList(),
      payment: payment?.toEntity(),
      notes: notes,
      estimatedDone: estimatedDone,
      completedAt: completedAt,
      canceledAt: canceledAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
