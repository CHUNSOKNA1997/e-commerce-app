import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../constants/colors.dart';
import '../state/auth_state.dart';
import '../state/catalog_state.dart';
import '../widgets/product_card.dart';
import '../widgets/promo_banner.dart';
import 'cart_screen.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool showBottomNav;
  final ValueChanged<int>? onTabSelected;

  const HomeScreen({
    super.key,
    this.showBottomNav = true,
    this.onTabSelected,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _promoController = PageController(viewportFraction: 0.9);

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
                    _buildProductSection(
                      title: 'Trending Now',
                      products: catalogState.trendingNow,
                      catalogState: catalogState,
                      emptyMessage: 'No trending products right now.',
                    ),
                    const SizedBox(height: 24),
                    _buildProductSection(
                      title: 'New Arrivals',
                      products: catalogState.newArrivals,
                      catalogState: catalogState,
                      emptyMessage: 'No new arrivals available yet.',
                    ),
                    const SizedBox(height: 24),
                    _buildProductSection(
                      title: 'Popular Near You',
                      products: catalogState.popularNearYou,
                      catalogState: catalogState,
                      emptyMessage: 'No popular products near you yet.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: widget.showBottomNav ? _buildBottomNav() : null,
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
            if (widget.onTabSelected != null) {
              widget.onTabSelected!(2);
            }
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

  Widget _buildProductSection({
    required String title,
    required List<dynamic> products,
    required CatalogState catalogState,
    required String emptyMessage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if (catalogState.isLoading) ...[
              const SizedBox(width: 10),
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
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
              emptyMessage,
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          )
        else
          SizedBox(
            height: 215,
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
          if (widget.onTabSelected != null) {
            widget.onTabSelected!(index);
            return;
          }
          if (index == 2) {
            return;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
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
}
