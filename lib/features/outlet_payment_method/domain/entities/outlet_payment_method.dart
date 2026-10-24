class OutletPaymentMethod {
  final String id;
  final String type;
  final String providerName;
  final String? accountNumber;
  final String accountName;
  final String? qrImageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  OutletPaymentMethod({
    required this.id,
    required this.type,
    required this.providerName,
    this.accountNumber,
    required this.accountName,
    this.qrImageUrl,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
}
