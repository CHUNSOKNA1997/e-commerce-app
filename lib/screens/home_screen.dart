import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../constants/colors.dart';
import '../models/category.dart';
import '../state/auth_state.dart';
import '../state/catalog_state.dart';
import '../widgets/category_chip.dart';
import '../widgets/product_card.dart';
import '../widgets/promo_banner.dart';
import 'cart_screen.dart';
import 'product_detail_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _promoController = PageController(viewportFraction: 0.9);
  int _selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authState = context.read<AuthState>();
      final catalogState = context.read<CatalogState>();

      await authState.refreshCurrentUser();
      await catalogState.loadInitialData();
    });
  }

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthState>();
    final catalogState = context.watch<CatalogState>();
    final categories = _buildCategoryList(catalogState.categories);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAppBar(authState),
                    const SizedBox(height: 24),
                    _buildTagline(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
              _buildPromoCarousel(),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCategories(categories),
                    const SizedBox(height: 32),
                    _buildRecommended(catalogState),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildAppBar(AuthState authState) {
    final user = authState.currentUser;
    final firstName = user?.firstName ?? 'Shopper';
    final avatarUrl = user?.avatarUrl;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ProfileScreen(initialNavIndex: 3),
              ),
            );
          },
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade300,
                ),
                clipBehavior: Clip.antiAlias,
                child: avatarUrl == null
                    ? const Icon(Icons.person, color: Colors.white)
                    : Image.network(
                        avatarUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.person, color: Colors.white);
                        },
                      ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello $firstName',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    user == null ? 'Start shopping' : 'Welcome back',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const CartScreen()));
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              color: AppColors.textPrimary,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTagline() {
    return RichText(
      text: TextSpan(
        style: GoogleFonts.nunito(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
          height: 1.2,
        ),
        children: const [
          TextSpan(text: 'Shop '),
          TextSpan(
            text: 'Fashion',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(text: ' in the easiest way\nall the time.'),
        ],
      ),
    );
  }

  Widget _buildPromoCarousel() {
    const banners = [
      'assets/images/promo-banner-1.jpg',
      'assets/images/promo-banner-2.jpg',
    ];

    return Padding(
      padding: const EdgeInsets.only(left: 24),
      child: Column(
        children: [
          SizedBox(
            height: 160,
            child: PageView.builder(
              controller: _promoController,
              padEnds: false,
              itemCount: banners.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: PromoBanner(imagePath: banners[index]),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          SmoothPageIndicator(
            controller: _promoController,
            count: banners.length,
            effect: ExpandingDotsEffect(
              activeDotColor: AppColors.primary,
              dotColor: Colors.grey.shade300,
              dotHeight: 6,
              dotWidth: 6,
              spacing: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(List<_CategoryItem> categories) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Categories',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'See all',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final category = categories[index];

              return CategoryChip(
                label: category.label,
                icon: category.icon,
                isSelected: _selectedCategoryIndex == index,
                onTap: () async {
                  setState(() => _selectedCategoryIndex = index);

                  await context.read<CatalogState>().loadProductsByCategory(
                    category.apiValue,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecommended(CatalogState catalogState) {
    final products = catalogState.products;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recommended for you',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if (catalogState.isLoading)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              TextButton(
                onPressed: () {},
                child: Text(
                  'See all',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (catalogState.errorMessage != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              catalogState.errorMessage!,
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: Colors.red.shade700,
                fontWeight: FontWeight.w700,
              ),
            ),
          )
        else if (!catalogState.isLoading && products.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'No products available for this category yet.',
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          )
        else
          SizedBox(
            height: 250,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];

                return ProductCard(
                  product: product,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(product: product),
                      ),
                    );
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -5),
            blurRadius: 20,
          ),
        ],
      ),
      child: BottomNavigationBar(
        elevation: 0,
        currentIndex: 0,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey.shade400,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 3) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ProfileScreen(initialNavIndex: index),
              ),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined),
            label: 'Shop',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  List<_CategoryItem> _buildCategoryList(List<Category> categories) {
    return [
      const _CategoryItem(label: 'All Items', icon: Icons.shopping_bag),
      ...categories.map(
        (category) => _CategoryItem(
          label: category.name,
          apiValue: category.name,
          icon: _iconForCategory(category.name),
        ),
      ),
    ];
  }

  static IconData _iconForCategory(String value) {
    final normalized = value.toLowerCase();

    if (normalized.contains('cloth') || normalized.contains('fashion')) {
      return Icons.checkroom;
    }
    if (normalized.contains('shoe')) {
      return Icons.ice_skating;
    }
    if (normalized.contains('watch')) {
      return Icons.watch;
    }
    if (normalized.contains('bag')) {
      return Icons.shopping_bag;
    }

    return Icons.category_outlined;
  }
}

class _CategoryItem {
  final String label;
  final String? apiValue;
  final IconData icon;

  const _CategoryItem({required this.label, required this.icon, this.apiValue});
}
