import '../config/app_config.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String imagePath;
  final List<String> imagePaths;
  final double rating;
  final bool isFavorite;
  final bool isNewArrival;
  final bool isTrending;
  final bool isPopularNearYou;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imagePath,
    this.imagePaths = const [],
    this.rating = 0.0,
    this.isFavorite = false,
    this.isNewArrival = false,
    this.isTrending = false,
    this.isPopularNearYou = false,
  });

  List<String> get galleryImagePaths {
    final normalized = imagePaths
        .map((path) => path.trim())
        .where((path) => path.isNotEmpty)
        .toList();

    if (normalized.isEmpty && imagePath.trim().isNotEmpty) {
      normalized.add(imagePath.trim());
    }

    return normalized;
  }

  String? get imageUrl {
    return resolveImageUrl(imagePath);
  }

  String? resolveImageUrl(String rawPath) {
    final path = rawPath.trim();
    if (path.isEmpty) {
      return null;
    }

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return '${AppConfig.apiOrigin}$normalizedPath';
  }

  String get normalizedImageAssetPath {
    return normalizeImageAssetPath(imagePath);
  }

  String normalizeImageAssetPath(String rawPath) {
    final path = rawPath.trim();
    if (path.isEmpty) {
      return path;
    }

    return path.startsWith('/') ? path.substring(1) : path;
  }

  bool get isSvgImage {
    return isSvgSource(imagePath);
  }

  bool isSvgSource(String rawPath) {
    final source = rawPath.toLowerCase();
    return source.endsWith('.svg');
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      category: json['category'] as String,
      imagePath: json['imagePath'] as String,
      imagePaths: (json['imagePaths'] as List<dynamic>? ?? const [])
          .map((item) => item as String)
          .toList(),
      rating: ((json['rating'] as num?) ?? 0).toDouble(),
      isFavorite: json['isFavorite'] as bool? ?? false,
      isNewArrival: json['isNewArrival'] as bool? ?? false,
      isTrending: json['isTrending'] as bool? ?? false,
      isPopularNearYou: json['isPopularNearYou'] as bool? ?? false,
    );
  }
}

// Dummy data for the UI
final List<Product> dummyProducts = [
  Product(
    id: '1',
    name: 'Abracadabra Shirt',
    description:
        'Crafted with attention to detail and designed for everyday confidence, this shirt blends comfort, style, and versatility. Made from high-quality fabric, it offers a smooth feel on the skin while maintaining a structured.',
    price: 4000.00,
    category: 'Unisex Wear',
    imagePath: 'assets/images/purple_hoodie.png', // Reusing placeholder
    imagePaths: const ['assets/images/purple_hoodie.png'],
    rating: 4.5,
    isFavorite: false,
  ),
  Product(
    id: '2',
    name: 'Panther Jacket',
    description: 'A stylish and comfortable jacket perfect for any occasion.',
    price: 5500.00,
    category: 'Female Wear',
    imagePath: 'assets/images/orange_coat.png', // Reusing placeholder
    imagePaths: const ['assets/images/orange_coat.png'],
    rating: 4.8,
    isFavorite: false,
  ),
];
