import '../config/app_config.dart';

class OrderItem {
  final String id;
  final String productId;
  final String name;
  final String description;
  final String category;
  final String imagePath;
  final double unitPrice;
  final double lineTotal;
  final int quantity;

  const OrderItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.description,
    required this.category,
    required this.imagePath,
    required this.unitPrice,
    required this.lineTotal,
    required this.quantity,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as String? ?? '',
      productId: json['productId'] as String? ?? '',
      name: json['name'] as String? ?? 'Unnamed Product',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      imagePath: json['imagePath'] as String? ?? '',
      unitPrice: ((json['unitPrice'] ?? json['price'] ?? 0) as num).toDouble(),
      lineTotal: ((json['lineTotal'] ?? json['total'] ?? json['price'] ?? 0) as num)
          .toDouble(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );
  }

  String? get imageUrl {
    final path = imagePath.trim();
    if (path.isEmpty) {
      return null;
    }
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return '${AppConfig.apiOrigin}$normalizedPath';
  }

  bool get isSvgImage => imagePath.toLowerCase().endsWith('.svg');
}

class Order {
  final String id;
  final String status;
  final List<OrderItem> items;
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
  int get totalQuantity =>
      items.fold(0, (sum, item) => sum + item.quantity);

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING',
      items: (json['items'] as List<dynamic>? ?? const [])
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      subTotal: ((json['subTotal'] ?? 0) as num).toDouble(),
      vat: ((json['vat'] ?? 0) as num).toDouble(),
      deliveryFee: ((json['deliveryFee'] ?? 0) as num).toDouble(),
      total: ((json['total'] ?? 0) as num).toDouble(),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
    );
  }
}
