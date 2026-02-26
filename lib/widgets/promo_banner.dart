import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PromoBanner extends StatelessWidget {
  final String imagePath;

  const PromoBanner({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final content = _resolveContent(imagePath);

    return LayoutBuilder(
      builder: (context, constraints) {
        final bannerWidth = constraints.maxWidth;
        final imageWidth = _clampDouble(bannerWidth * 0.44, 136, 182);
        final titleSize = _clampDouble(bannerWidth * 0.058, 16, 19);
        final subtitleSize = _clampDouble(bannerWidth * 0.036, 11, 12.5);
        final sectionPadding = _clampDouble(bannerWidth * 0.05, 14, 18);
        final textRightPadding = imageWidth - 8;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: content.gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: content.gradientColors.last.withValues(alpha: 0.28),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned(
                top: -34,
                right: -18,
                child: _buildCircle(118, Colors.white.withValues(alpha: 0.18)),
              ),
              Positioned(
                bottom: -42,
                right: 56,
                child: _buildCircle(124, Colors.white.withValues(alpha: 0.12)),
              ),
              Positioned(
                top: 34,
                right: 104,
                child: _buildCircle(14, Colors.white.withValues(alpha: 0.35)),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  sectionPadding,
                  14,
                  textRightPadding,
                  14,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      content.title,
                      style: GoogleFonts.outfit(
                        fontSize: titleSize,
                        height: 1.05,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 7),
                    Text(
                      content.subtitle,
                      style: GoogleFonts.inter(
                        fontSize: subtitleSize,
                        height: 1.25,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        content.ctaLabel,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: content.ctaTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: -2,
                top: 8,
                bottom: 0,
                width: imageWidth,
                child: Transform.translate(
                  offset: const Offset(0, 12),
                  child: Image.asset(
                    content.productImagePath,
                    fit: BoxFit.contain,
                    alignment: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static double _clampDouble(double value, double min, double max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  static Widget _buildCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  static _PromoContent _resolveContent(String imagePath) {
    if (imagePath.contains('promo-banner-2')) {
      return const _PromoContent(
        title: 'New Collection\nAvailable',
        subtitle: '55% Discount for your\nfirst transaction.',
        ctaLabel: 'Shop now',
        productImagePath: 'assets/images/purple_hoodie.png',
        gradientColors: [Color(0xFF8C63FF), Color(0xFF6F4EED)],
        ctaTextColor: Color(0xFF6F4EED),
      );
    }

    return _PromoContent(
      title: 'New Collection\nAvailable',
      subtitle: '50% Discount for the\nfirst transaction.',
      ctaLabel: 'Shop now',
      productImagePath: imagePath.contains('promo-banner-1')
          ? 'assets/images/orange_coat.png'
          : imagePath,
      gradientColors: const [Color(0xFFFF6A00), Color(0xFFFF4D00)],
      ctaTextColor: const Color(0xFFFF4D00),
    );
  }
}

class _PromoContent {
  final String title;
  final String subtitle;
  final String ctaLabel;
  final String productImagePath;
  final List<Color> gradientColors;
  final Color ctaTextColor;

  const _PromoContent({
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.productImagePath,
    required this.gradientColors,
    required this.ctaTextColor,
  });
}
