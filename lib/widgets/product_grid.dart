import 'package:flutter/material.dart';

class ProductGrid extends StatelessWidget {
  const ProductGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> products = [
      {'image': 'assets/images/orange_coat.png', 'span': 2},
      {'image': 'assets/images/purple_hoodie.png', 'span': 1},
      {'color': const Color(0xFF000000), 'span': 1}, // Black heels placeholder
      {'color': const Color(0xFFD2B48C), 'span': 1}, // Tan blazer placeholder
      {'color': const Color(0xFFFFB6C1), 'span': 1}, // Pink bomber placeholder
      {'color': const Color(0xFFF5F5DC), 'span': 1}, // Cream pants placeholder
      {'color': const Color(0xFF9370DB), 'span': 1}, // Purple shirt placeholder
      {'color': const Color(0xFF000000), 'span': 1}, // Black shoes placeholder
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.75,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[100],
          ),
          clipBehavior: Clip.antiAlias,
          child: product.containsKey('image')
              ? Image.asset(
                  product['image'],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.image,
                        size: 50,
                        color: Colors.grey,
                      ),
                    );
                  },
                )
              : Container(
                  color: product['color'],
                  child: const Center(
                    child: Icon(Icons.checkroom, size: 50, color: Colors.white),
                  ),
                ),
        );
      },
    );
  }
}
