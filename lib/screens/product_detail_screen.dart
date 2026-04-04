import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../constants/colors.dart';
import '../models/product.dart';
import '../services/account_service.dart';
import '../services/catalog_service.dart';
import '../state/cart_state.dart';
import '../utils/currency_formatter.dart';
import '../widgets/product_image.dart';
import '../widgets/skeleton_box.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final PageController _imageController = PageController();
  late Product _product;
  int _currentImagePage = 0;
  int _quantity = 1;
  bool _isFavorite = false;
  bool _isLoading = true;
  bool _isAddingToCart = false;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _isFavorite = widget.product.isFavorite;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProduct());
  }

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _loadProduct() async {
    try {
      final catalogService = context.read<CatalogService>();
      final accountService = context.read<AccountService>();
      final product = await catalogService.getProductById(widget.product.id);
      final wishlistItems = await accountService.getWishlistItems();
      final wishlistIds = wishlistItems.map((item) => item.productId).toSet();

      if (!mounted) return;
      setState(() {
        _product = product;
        _isFavorite = wishlistIds.contains(product.id);
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 18),
                  child: _isLoading
                      ? _buildDetailsSkeleton()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeroImage(),
                            const SizedBox(height: 18),
                            _buildTitlePriceRow(),
                            const SizedBox(height: 8),
                            _buildMetaRow(),
                            const SizedBox(height: 18),
                            _buildDetailsSection(),
                          ],
                        ),
                ),
              ),
            ),
            _buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      child: SizedBox(
        height: 42,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFEDEDED)),
                  ),
                  child: const Icon(
                    Icons.chevron_left,
                    size: 22,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            Text(
              'Product Details',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroImage() {
    final imagePaths = _product.galleryImagePaths;

    return Container(
      height: 320,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFFECECEC),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          PageView.builder(
            controller: _imageController,
            itemCount: imagePaths.length,
            onPageChanged: (index) => setState(() => _currentImagePage = index),
            itemBuilder: (context, index) {
              return ProductImage(
                product: _product,
                imagePathOverride: imagePaths[index],
                fit: BoxFit.cover,
                fallback: Container(
                  color: const Color(0xFFECECEC),
                  child: const Center(
                    child: Icon(
                      Icons.image_outlined,
                      size: 70,
                      color: AppColors.grey,
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: 12,
            right: 12,
            child: GestureDetector(
              onTap: _toggleFavorite,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.88),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  size: 18,
                  color: _isFavorite ? const Color(0xFFFF6B6B) : AppColors.grey,
                ),
              ),
            ),
          ),
          if (imagePaths.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(imagePaths.length, (index) {
                  final active = index == _currentImagePage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    height: 5,
                    width: active ? 16 : 5,
                    decoration: BoxDecoration(
                      color: active ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailsSkeleton() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonBox(
          width: double.infinity,
          height: 320,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: SkeletonBox(width: double.infinity, height: 32)),
            SizedBox(width: 12),
            SkeletonBox(width: 96, height: 34),
          ],
        ),
        SizedBox(height: 12),
        SkeletonBox(width: 180, height: 14),
        SizedBox(height: 22),
        SkeletonBox(width: 72, height: 22),
        SizedBox(height: 10),
        SkeletonBox(width: double.infinity, height: 12),
        SizedBox(height: 8),
        SkeletonBox(width: double.infinity, height: 12),
        SizedBox(height: 8),
        SkeletonBox(width: 220, height: 12),
      ],
    );
  }

  Widget _buildTitlePriceRow() {
    final price = formatCurrency(_product.price);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            _product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.nunito(
              fontSize: 30,
              height: 1,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        RichText(
          text: TextSpan(
            text: price,
            style: GoogleFonts.nunito(
              fontSize: 34,
              height: 1,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetaRow() {
    return Row(
      children: [
        const Icon(Icons.shopping_bag, size: 14, color: AppColors.textPrimary),
        const SizedBox(width: 5),
        Text(
          _product.category,
          style: GoogleFonts.nunito(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '|',
          style: GoogleFonts.nunito(fontSize: 13, color: const Color(0xFFCACACA)),
        ),
        const SizedBox(width: 12),
        const Icon(Icons.star, size: 14, color: Color(0xFFFFB228)),
        const SizedBox(width: 4),
        Text(
          _product.rating.toStringAsFixed(1),
          style: GoogleFonts.nunito(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Details',
          style: GoogleFonts.nunito(
            fontSize: 21,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _product.description.trim(),
          style: GoogleFonts.nunito(
            fontSize: 13,
            height: 1.55,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 12, 24, safeBottom + 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFFEAEAEA)),
            ),
            child: Row(
              children: [
                _buildQuantityButton(
                  icon: Icons.remove,
                  onTap: _quantity > 1
                      ? () => setState(() => _quantity -= 1)
                      : null,
                ),
                SizedBox(
                  width: 28,
                  child: Text(
                    '$_quantity',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                _buildQuantityButton(
                  icon: Icons.add,
                  onTap: _quantity < 99
                      ? () => setState(() => _quantity += 1)
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isAddingToCart ? null : _handleAddToCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: _isAddingToCart
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Add to Cart',
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: onTap == null ? const Color(0xFFEFEFEF) : Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18,
          color: onTap == null
              ? const Color(0xFFBDBDBD)
              : AppColors.textPrimary,
        ),
      ),
    );
  }

  Future<void> _handleAddToCart() async {
    setState(() => _isAddingToCart = true);

    try {
      await context.read<CartState>().addItem(
        productId: _product.id,
        quantity: _quantity,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Added $_quantity item${_quantity > 1 ? 's' : ''} to cart',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString(),
            style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isAddingToCart = false);
      }
    }
  }

  Future<void> _toggleFavorite() async {
    final nextValue = !_isFavorite;

    try {
      if (_isFavorite) {
        await context.read<AccountService>().removeWishlistItem(
          productId: _product.id,
        );
      } else {
        await context.read<AccountService>().addWishlistItem(
          productId: _product.id,
        );
      }

      if (!mounted) return;
      setState(() => _isFavorite = nextValue);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            nextValue ? 'Added to wishlist' : 'Removed from wishlist',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString(),
            style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
          ),
        ),
      );
    }
  }
}
