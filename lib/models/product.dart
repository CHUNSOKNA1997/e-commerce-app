class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String imagePath;
  final double rating;
  final bool isFavorite;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imagePath,
    this.rating = 0.0,
    this.isFavorite = false,
  });
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
    rating: 4.8,
    isFavorite: false,
  ),
];
