import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../constants/colors.dart';
import '../models/cart.dart';
import '../state/cart_state.dart';
import '../utils/currency_formatter.dart';
import '../widgets/skeleton_box.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartSummarySkeletonRow extends StatelessWidget {
  final bool total;

  const _CartSummarySkeletonRow({this.total = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SkeletonBox(width: total ? 72 : 52, height: total ? 18 : 14),
        const Spacer(),
        SkeletonBox(width: total ? 104 : 78, height: total ? 20 : 16),
      ],
    );
  }
}

class _CartScreenState extends State<CartScreen> {
  final Set<String> _pendingItemIds = <String>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartState>().loadCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;
    final cartState = context.watch<CartState>();
    final cartItems = cartState.items;
    final summary = cartState.summary;
    final isCartEmpty = cartItems.isEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: cartState.isLoading
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(14, 8, 14, 18),
                      child: _buildCartSkeleton(),
                    )
                  : cartState.errorMessage != null
                  ? _buildErrorState(cartState)
                  : isCartEmpty
                  ? _buildEmptyState()
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(14, 8, 14, 18),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: cartItems.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          return _buildCartItemCard(cartItems[index]);
                        },
                      ),
                    ),
            ),
            _buildCheckoutArea(
              safeBottom,
              isCartEmpty: isCartEmpty,
              summary: summary,
              total: summary.total,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartSkeleton() {
    return Column(
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) => Container(
            padding: const EdgeInsets.fromLTRB(8, 8, 10, 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEFEFEF)),
            ),
            child: Row(
              children: const [
                SkeletonBox(width: 50, height: 50, borderRadius: BorderRadius.all(Radius.circular(8))),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(width: 150, height: 18),
                      SizedBox(height: 8),
                      SkeletonBox(width: 90, height: 12),
                    ],
                  ),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SkeletonBox(width: 58, height: 18),
                    SizedBox(height: 10),
                    SkeletonBox(width: 16, height: 16),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFEFEFEF)),
          ),
          child: const Column(
            children: [
              _CartSummarySkeletonRow(),
              SizedBox(height: 8),
              _CartSummarySkeletonRow(),
              SizedBox(height: 8),
              _CartSummarySkeletonRow(),
              Divider(height: 18),
              _CartSummarySkeletonRow(total: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: SizedBox(
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: _roundIconButton(
                icon: Icons.chevron_left,
                onTap: () => Navigator.of(context).pop(),
              ),
            ),
            Text(
              'Cart',
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roundIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Ink(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE8E8E8)),
        ),
        child: Icon(icon, size: 22, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildCartItemCard(CartItem item) {
    final isPending = _pendingItemIds.contains(item.id);

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 10, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEFEFEF)),
      ),
      child: Row(
        children: [
          _buildProductThumb(item),
          const SizedBox(width: 10),
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
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 1),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.nunito(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildMoneyText(
                      item.price,
                      mainSize: 15.5,
                      decimalSize: 10.5,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _qtyTextButton(
                    text: '-',
                    onTap: isPending || item.quantity <= 1
                        ? null
                        : () => _changeQuantity(item, item.quantity - 1),
                    textColor: const Color(0xFF6E6E6E),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 14,
                    child: Text(
                      '${item.quantity}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: isPending
                        ? null
                        : () => _changeQuantity(item, item.quantity + 1),
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: isPending ? null : () => _removeItem(item),
                child: const Icon(
                  Icons.delete_outline,
                  size: 16,
                  color: Color(0xFFD87070),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductThumb(CartItem item) {
    final imageUrl = item.imageUrl;
    final fallback = const Icon(Icons.image_outlined, color: AppColors.grey);

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 50,
        height: 50,
        color: const Color(0xFFF1F1F1),
        child: imageUrl != null
            ? item.isSvgImage
                ? fallback
                : Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return fallback;
                    },
                  )
            : const Icon(
                Icons.hiking_outlined,
                color: AppColors.textSecondary,
              ),
      ),
    );
  }

  Widget _qtyTextButton({
    required String text,
    required VoidCallback? onTap,
    required Color textColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: textColor,
        ),
      ),
    );
  }

  Future<void> _changeQuantity(CartItem item, int quantity) async {
    setState(() => _pendingItemIds.add(item.id));

    try {
      await context.read<CartState>().updateItemQuantity(
        cartItemId: item.id,
        quantity: quantity,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _pendingItemIds.remove(item.id));
      }
    }
  }

  Future<void> _removeItem(CartItem item) async {
    setState(() => _pendingItemIds.add(item.id));

    try {
      await context.read<CartState>().removeItem(cartItemId: item.id);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _pendingItemIds.remove(item.id));
      }
    }
  }

  Widget _buildSummaryCard(CartSummary summary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEFEFEF)),
      ),
      child: Column(
        children: [
          _summaryRow('Price', summary.subTotal),
          const SizedBox(height: 8),
          _summaryRow('VAT', summary.vat),
          const SizedBox(height: 8),
          _summaryRow('Delivery Fee', summary.deliveryFee),
          const Divider(height: 18),
          _summaryRow('Total', summary.total, isTotal: true),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, double amount, {bool isTotal = false}) {
    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: isTotal ? 17 : 15,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        _buildMoneyText(
          amount,
          mainSize: isTotal ? 20 : 16,
          decimalSize: 11,
          color: isTotal ? AppColors.primary : AppColors.textPrimary,
        ),
      ],
    );
  }

  Widget _buildCheckoutArea(
    double safeBottom, {
    required bool isCartEmpty,
    required CartSummary summary,
    required double total,
  }) {
    return Container(
      padding: EdgeInsets.fromLTRB(14, 10, 14, safeBottom + 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isCartEmpty) ...[
            _buildSummaryCard(summary),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: isCartEmpty
                  ? null
                  : () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CheckoutScreen(),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.primary.withValues(
                  alpha: 0.45,
                ),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: Text(
                isCartEmpty
                    ? 'Add items to continue'
                    : 'Continue to Pay ${formatCurrency(total)}',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(CartState cartState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 40,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load cart',
              style: GoogleFonts.nunito(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              cartState.errorMessage ?? 'Something went wrong.',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: cartState.loadCart,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Your cart is empty',
              style: GoogleFonts.nunito(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Looks like you have not added anything yet.',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoneyText(
    double amount, {
    required double mainSize,
    required double decimalSize,
    Color color = AppColors.textPrimary,
  }) {
    return Text(
      formatCurrency(amount),
      style: GoogleFonts.nunito(
        fontSize: mainSize,
        fontWeight: FontWeight.w800,
        color: color,
      ),
    );
  }
}
