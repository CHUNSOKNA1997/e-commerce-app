import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<_CartItem> _cartItems = const [
    _CartItem(
      id: '1',
      name: 'Abracadabra Shirt',
      category: 'Unisex Wear',
      price: 4000.00,
      quantity: 2,
      imagePath: 'assets/images/purple_hoodie.png',
    ),
    _CartItem(
      id: '2',
      name: 'Panther Jacket',
      category: 'Unisex Wear',
      price: 2500.89,
      quantity: 2,
      imagePath: 'assets/images/orange_coat.png',
    ),
    _CartItem(
      id: '3',
      name: 'Paul Elite Shoe',
      category: 'Male Wear',
      price: 2500.89,
      quantity: 5,
      imagePath: '',
    ),
    _CartItem(
      id: '4',
      name: 'Sambizza Fitz',
      category: 'Male Wear',
      price: 6340.00,
      quantity: 4,
      imagePath: 'assets/images/purple_hoodie.png',
    ),
  ];

  bool get _isCartEmpty => _cartItems.isEmpty;

  double get _subTotal =>
      _cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));

  double get _vat => _isCartEmpty ? 0 : 350.00;

  double get _deliveryFee => _isCartEmpty ? 0 : 150.00;

  double get _total => _subTotal + _vat + _deliveryFee;

  void _decreaseQty(int index) {
    final current = _cartItems[index];
    if (current.quantity <= 1) return;

    setState(() {
      _cartItems[index] = current.copyWith(quantity: current.quantity - 1);
    });
  }

  void _increaseQty(int index) {
    final current = _cartItems[index];
    setState(() {
      _cartItems[index] = current.copyWith(quantity: current.quantity + 1);
    });
  }

  void _removeItem(String itemId) {
    setState(() {
      _cartItems = _cartItems.where((item) => item.id != itemId).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: _isCartEmpty
                  ? _buildEmptyState()
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(14, 8, 14, 18),
                      child: Column(
                        children: [
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _cartItems.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              return _buildCartItemCard(index);
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildSummaryCard(),
                        ],
                      ),
                    ),
            ),
            _buildCheckoutArea(safeBottom),
          ],
        ),
      ),
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

  Widget _buildCartItemCard(int index) {
    final item = _cartItems[index];

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
                    onTap: () => _decreaseQty(index),
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
                    onTap: () => _increaseQty(index),
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
                onTap: () => _removeItem(item.id),
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

  Widget _buildProductThumb(_CartItem item) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 50,
        height: 50,
        color: const Color(0xFFF1F1F1),
        child: item.imagePath.isNotEmpty
            ? Image.asset(
                item.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.image_outlined, color: AppColors.grey);
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
    required VoidCallback onTap,
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

  Widget _buildSummaryCard() {
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
          _summaryRow('Price', _subTotal),
          const SizedBox(height: 8),
          _summaryRow('VAT', _vat),
          const SizedBox(height: 8),
          _summaryRow('Delivery Fee', _deliveryFee),
          const Divider(height: 18),
          _summaryRow('Total', _total, isTotal: true),
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

  Widget _buildCheckoutArea(double safeBottom) {
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
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: _isCartEmpty ? null : () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.45),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          child: Text(
            _isCartEmpty
                ? 'Add items to continue'
                : 'Continue to Pay \$${_formatMoney(_total)}',
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
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
    final formatted = _formatMoney(amount);
    final parts = formatted.split('.');
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '\$${parts[0]}',
            style: GoogleFonts.nunito(
              fontSize: mainSize,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          TextSpan(
            text: '.${parts[1]}',
            style: GoogleFonts.nunito(
              fontSize: decimalSize,
              fontWeight: FontWeight.w700,
              color: color.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }

  String _formatMoney(double value) {
    final fixed = value.toStringAsFixed(2);
    final parts = fixed.split('.');
    final whole = parts[0].replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
    return '$whole.${parts[1]}';
  }
}

class _CartItem {
  final String id;
  final String name;
  final String category;
  final double price;
  final int quantity;
  final String imagePath;

  const _CartItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.quantity,
    required this.imagePath,
  });

  _CartItem copyWith({
    String? id,
    String? name,
    String? category,
    double? price,
    int? quantity,
    String? imagePath,
  }) {
    return _CartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}
