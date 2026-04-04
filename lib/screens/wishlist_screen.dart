import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../constants/colors.dart';
import '../models/product.dart';
import '../models/wishlist_item.dart';
import '../services/account_service.dart';
import '../utils/currency_formatter.dart';
import '../widgets/product_image.dart';
import '../widgets/skeleton_box.dart';
import 'product_detail_screen.dart';

class WishlistScreen extends StatefulWidget {
  final bool isActive;

  const WishlistScreen({
    super.key,
    this.isActive = false,
  });

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  late Future<List<WishlistItem>> _wishlistFuture;

  @override
  void initState() {
    super.initState();
    _wishlistFuture = context.read<AccountService>().getWishlistItems();
  }

  @override
  void didUpdateWidget(covariant WishlistScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isActive && widget.isActive) {
      _wishlistFuture = context.read<AccountService>().getWishlistItems();
    }
  }

  Future<void> _reload() async {
    setState(() {
      _wishlistFuture = context.read<AccountService>().getWishlistItems();
    });
    await _wishlistFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Favorites',
                style: GoogleFonts.nunito(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: FutureBuilder<List<WishlistItem>>(
                  future: _wishlistFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return ListView.separated(
                        padding: const EdgeInsets.only(bottom: 24),
                        itemCount: 4,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) =>
                            const _WishlistCardSkeleton(),
                      );
                    }

                    if (snapshot.hasError) {
                      return _WishlistStateView(
                        icon: Icons.error_outline,
                        title: 'Unable to load favorites',
                        subtitle: snapshot.error.toString(),
                        actionLabel: 'Retry',
                        onAction: _reload,
                      );
                    }

                    final items = snapshot.data ?? const [];
                    if (items.isEmpty) {
                      return _WishlistStateView(
                        icon: Icons.favorite_border,
                        title: 'Favorites',
                        subtitle: 'Favorite items will appear here.',
                        actionLabel: null,
                        onAction: null,
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: _reload,
                      color: AppColors.primary,
                      child: ListView.separated(
                        padding: const EdgeInsets.only(bottom: 24),
                        itemCount: items.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _WishlistCard(item: item);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WishlistCardSkeleton extends StatelessWidget {
  const _WishlistCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEFEFEF)),
      ),
      child: const Row(
        children: [
          SkeletonBox(
            width: 86,
            height: 86,
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 146, height: 18),
                SizedBox(height: 8),
                SkeletonBox(width: 90, height: 12),
                SizedBox(height: 12),
                SkeletonBox(width: 118, height: 18),
              ],
            ),
          ),
          SizedBox(width: 8),
          SkeletonBox(width: 14, height: 18),
        ],
      ),
    );
  }
}

class _WishlistCard extends StatelessWidget {
  final WishlistItem item;

  const _WishlistCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final product = Product(
      id: item.productId,
      name: item.name,
      description: item.description,
      price: item.price,
      category: item.category,
      imagePath: item.imagePath,
      rating: item.rating,
      isFavorite: true,
    );

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFEFEFEF)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 86,
                height: 86,
                child: ProductImage(
                  product: product,
                  fallback: Container(
                    color: const Color(0xFFF2F2F2),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.image_outlined,
                      color: AppColors.grey,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.category,
                    style: GoogleFonts.nunito(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        formatCurrency(item.price),
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.star,
                        size: 14,
                        color: Color(0xFFFFB228),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.rating.toStringAsFixed(1),
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Color(0xFFB7B7B7)),
          ],
        ),
      ),
    );
  }
}

class _WishlistStateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final Future<void> Function()? onAction;

  const _WishlistStateView({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 42, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.nunito(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
