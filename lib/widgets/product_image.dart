import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/colors.dart';
import '../models/product.dart';

class ProductImage extends StatelessWidget {
  final Product product;
  final BoxFit fit;
  final Widget? fallback;

  const ProductImage({
    super.key,
    required this.product,
    this.fit = BoxFit.cover,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final fallbackWidget =
        fallback ??
        const Center(
          child: Icon(
            Icons.image_outlined,
            size: 36,
            color: AppColors.grey,
          ),
        );

    if (product.isSvgImage) {
      final imageUrl = product.imageUrl;
      if (imageUrl == null) {
        return fallbackWidget;
      }

      return SvgPicture.network(
        imageUrl,
        fit: fit,
        placeholderBuilder: (context) => fallbackWidget,
      );
    }

    final imageUrl = product.imageUrl;
    if (imageUrl != null && product.imagePath.startsWith('/')) {
      return Image.network(
        imageUrl,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => fallbackWidget,
      );
    }

    return Image.asset(
      product.normalizedImageAssetPath,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => fallbackWidget,
    );
  }
}
