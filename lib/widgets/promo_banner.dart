import 'package:flutter/material.dart';

class PromoBanner extends StatelessWidget {
  final String imagePath;

  const PromoBanner({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(imagePath, fit: BoxFit.cover, width: double.infinity),
    );
  }
}
