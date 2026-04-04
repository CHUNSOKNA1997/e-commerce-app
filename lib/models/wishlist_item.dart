class WishlistItem {
  final String productId;
  final String name;
  final String description;
  final double price;
  final String category;
  final String imagePath;
  final double rating;

  const WishlistItem({
    required this.productId,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imagePath,
    required this.rating,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      productId: json['productId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: ((json['price'] ?? 0) as num).toDouble(),
      category: json['category'] as String? ?? '',
      imagePath: json['imagePath'] as String? ?? '',
      rating: ((json['rating'] ?? 0) as num).toDouble(),
    );
  }
}
