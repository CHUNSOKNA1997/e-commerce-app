class Order {
  final String id;
  final String status;
  final List<dynamic> items;
  final double subTotal;
  final double vat;
  final double deliveryFee;
  final double total;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Order({
    required this.id,
    required this.status,
    required this.items,
    required this.subTotal,
    required this.vat,
    required this.deliveryFee,
    required this.total,
    this.createdAt,
    this.updatedAt,
  });

  int get itemCount => items.length;

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING',
      items: json['items'] as List<dynamic>? ?? const [],
      subTotal: ((json['subTotal'] ?? 0) as num).toDouble(),
      vat: ((json['vat'] ?? 0) as num).toDouble(),
      deliveryFee: ((json['deliveryFee'] ?? 0) as num).toDouble(),
      total: ((json['total'] ?? 0) as num).toDouble(),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
    );
  }
}
