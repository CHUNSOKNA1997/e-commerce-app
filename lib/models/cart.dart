import '../config/app_config.dart';

class Cart {
  final String id;
  final List<CartItem> items;
  final CartSummary summary;
  final DateTime? updatedAt;

  const Cart({
    required this.id,
    required this.items,
    required this.summary,
    this.updatedAt,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    final items = json['items'] as List<dynamic>? ?? const [];

    return Cart(
      id: json['id'] as String? ?? '',
      items: items
          .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      summary: CartSummary.fromJson(
        json['summary'] as Map<String, dynamic>? ?? const {},
      ),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
    );
  }
}

class CartItem {
  final String id;
  final String name;
  final String category;
  final double price;
  final int quantity;
  final String? imagePath;

  const CartItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.quantity,
    this.imagePath,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>?;

    return CartItem(
      id: (json['id'] ?? json['productId'] ?? product?['id'] ?? '') as String,
      name: (json['name'] ?? product?['name'] ?? 'Unknown item') as String,
      category:
          (json['category'] ?? product?['category'] ?? 'Uncategorized')
              as String,
      price:
          ((json['unitPrice'] ?? json['price'] ?? product?['price'] ?? 0) as num)
              .toDouble(),
      quantity: (json['quantity'] as num? ?? 1).toInt(),
      imagePath:
          (json['imagePath'] ?? product?['imagePath']) as String?,
    );
  }

  String? get imageUrl {
    final source = imagePath?.trim();
    if (source == null || source.isEmpty) {
      return null;
    }

    if (source.startsWith('http://') || source.startsWith('https://')) {
      return source;
    }

    final normalizedPath = source.startsWith('/') ? source : '/$source';
    return '${AppConfig.apiOrigin}$normalizedPath';
  }

  bool get isSvgImage {
    final source = imagePath?.toLowerCase() ?? '';
    return source.endsWith('.svg');
  }
}

class CartSummary {
  final double subTotal;
  final double vat;
  final double deliveryFee;
  final double total;

  const CartSummary({
    required this.subTotal,
    required this.vat,
    required this.deliveryFee,
    required this.total,
  });

  factory CartSummary.fromJson(Map<String, dynamic> json) {
    return CartSummary(
      subTotal: ((json['subTotal'] ?? 0) as num).toDouble(),
      vat: ((json['vat'] ?? 0) as num).toDouble(),
      deliveryFee: ((json['deliveryFee'] ?? 0) as num).toDouble(),
      total: ((json['total'] ?? 0) as num).toDouble(),
    );
  }
}
