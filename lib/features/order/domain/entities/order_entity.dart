import 'package:lavendera/features/service/domain/entities/service_item.dart';

class OrderPayment {
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

  OrderPayment({
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
}

class OrderItemService {
  final String id;
  final String name;
  final num price;
  final int durationDays;
  final ServiceCategorySummary category;

  OrderItemService({
    required this.id,
    required this.name,
    required this.price,
    required this.durationDays,
    required this.category,
  });
}

class OrderItem {
  final String id;
  final num price;
  final num quantity;
  final String unit;
  final num subtotal;
  final OrderItemService service;

  OrderItem({
    required this.id,
    required this.price,
    required this.quantity,
    required this.unit,
    required this.subtotal,
    required this.service,
  });
}

class OrderOutlet {
  final String id;
  final String name;
  final String? phone;
  final String? address;

  OrderOutlet({required this.id, required this.name, this.phone, this.address});
}

class OrderCustomer {
  final String id;
  final String name;
  final String? phone;
  final String? address;

  OrderCustomer({
    required this.id,
    required this.name,
    this.phone,
    this.address,
  });
}

class OrderDiscount {
  final String id;
  final String name;
  final String type;
  final num value;

  OrderDiscount({
    required this.id,
    required this.name,
    required this.type,
    required this.value,
  });
}

class OrderCreator {
  final String id;
  final String name;

  OrderCreator({required this.id, required this.name});
}

class OrderEntity {
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
  final OrderOutlet outlet;
  final OrderCustomer customer;
  final OrderDiscount? discount;
  final OrderCreator? creator;
  final List<OrderItem> items;
  final OrderPayment? payment;
  final String? notes;
  final DateTime? estimatedDone;
  final DateTime? completedAt;
  final DateTime? canceledAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderEntity({
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
}
