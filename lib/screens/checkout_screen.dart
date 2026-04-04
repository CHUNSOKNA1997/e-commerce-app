import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../constants/colors.dart';
import '../models/payment_checkout.dart';
import '../state/cart_state.dart';
import '../services/cart_service.dart';
import '../utils/currency_formatter.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isSubmitting = false;

  Future<void> _placeOrder() async {
    final currentTotal = context.read<CartState>().summary.total;
    if (currentTotal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Your cart is empty.',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
          ),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final navigator = Navigator.of(context);
      final messenger = ScaffoldMessenger.of(context);
      final cartState = context.read<CartState>();
      final cartService = context.read<CartService>();
      final order = await cartState.createOrder();
      final checkout = await cartService.createCheckout(
        amount: order.total,
        orderId: order.id,
      );

      if (!mounted) return;
      final paymentSucceeded =
          await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _CheckoutWebSheet(checkout: checkout),
      ) ??
          false;
      if (!mounted) return;
      if (paymentSucceeded) {
        navigator.pop();
        navigator.pop();
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'Payment completed successfully.',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
            ),
          ),
        );
      }
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
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = context.watch<CartState>();
    final summary = cartState.summary;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Method',
                      style: GoogleFonts.nunito(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildKhqrCard(),
                    const SizedBox(height: 24),
                    Text(
                      'Order Summary',
                      style: GoogleFonts.nunito(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildSummaryCard(summary.subTotal, summary.vat,
                        summary.deliveryFee, summary.total),
                  ],
                ),
              ),
            ),
            _buildBottomAction(summary.total),
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
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(999),
                child: Ink(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE8E8E8)),
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
              'Checkout',
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

  Widget _buildKhqrCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary, width: 1.1),
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF12B31),
              borderRadius: BorderRadius.circular(10),
            ),
            child: SvgPicture.asset('assets/payway/khqr.svg'),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ABA KHQR',
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Scan to pay with any banking app',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    double subTotal,
    double vat,
    double deliveryFee,
    double total,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEFEFEF)),
      ),
      child: Column(
        children: [
          _summaryRow('Price', subTotal),
          const SizedBox(height: 10),
          _summaryRow('VAT', vat),
          const SizedBox(height: 10),
          _summaryRow('Delivery Fee', deliveryFee),
          const Divider(height: 24),
          _summaryRow('Total', total, isTotal: true),
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
        Text(
          formatCurrency(amount),
          style: GoogleFonts.nunito(
            fontSize: isTotal ? 20 : 15,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w700,
            color: isTotal ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomAction(double total) {
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, safeBottom + 12),
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
          onPressed: _isSubmitting ? null : _placeOrder,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.45),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: Colors.white,
                  ),
                )
              : Text(
                  'Pay ${formatCurrency(total)}',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
        ),
      ),
    );
  }
}

class _CheckoutWebSheet extends StatefulWidget {
  final PaymentCheckout checkout;

  const _CheckoutWebSheet({required this.checkout});

  @override
  State<_CheckoutWebSheet> createState() => _CheckoutWebSheetState();
}

class _CheckoutWebSheetState extends State<_CheckoutWebSheet> {
  late final WebViewController _controller;
  Timer? _statusTimer;
  bool _hasCompleted = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final checkoutUrl = widget.checkout.resolvedCheckoutUrl;

    if (checkoutUrl.isEmpty) {
      _isLoading = false;
      return;
    }

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) {
              setState(() => _isLoading = true);
            }
          },
          onPageFinished: (_) {
            _hideMerchantLogo();
            Future<void>.delayed(
              const Duration(milliseconds: 350),
              _hideMerchantLogo,
            );
            if (mounted) {
              setState(() => _isLoading = false);
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(checkoutUrl));

    _statusTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _checkPaymentStatus(),
    );
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFFD8D8D8),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 2, 12, 0),
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 32,
                  height: 32,
                ),
                icon: const Icon(Icons.close),
              ),
            ),
          ),
          Expanded(
            child: widget.checkout.resolvedCheckoutUrl.isEmpty
                ? Center(
                    child: Text(
                      'Checkout URL is unavailable.',
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                : Stack(
                    children: [
                      WebViewWidget(controller: _controller),
                      if (_isLoading)
                        const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                    ],
                  ),
          ),
          SizedBox(height: bottomInset),
        ],
      ),
    );
  }

  Future<void> _hideMerchantLogo() async {
    try {
      await _controller.runJavaScript('''
        (() => {
          document.body.style.marginTop = '0';
          document.body.style.paddingTop = '0';

          const firstBlock = document.body.firstElementChild;
          if (firstBlock) {
            firstBlock.style.marginTop = '0';
            firstBlock.style.paddingTop = '0';
          }

          const images = Array.from(document.querySelectorAll('img'));
          if (images.length < 2) return;

          const standalone = images.find((img) => {
            const rect = img.getBoundingClientRect();
            return rect.top < window.innerHeight * 0.35 && rect.width < 120 && rect.height < 120;
          });

          if (!standalone) return;

          const parent = standalone.parentElement;
          standalone.style.display = 'none';
          if (parent && parent.children.length === 1) {
            parent.style.display = 'none';
          }

          const topCandidates = Array.from(document.querySelectorAll('div, section, header'))
            .filter((el) => {
              const rect = el.getBoundingClientRect();
              return rect.top < window.innerHeight * 0.2 && rect.height > 40 && rect.height < 220;
            });

          for (const el of topCandidates) {
            if (el.contains(standalone)) {
              el.style.display = 'none';
              break;
            }
          }
        })();
      ''');
    } catch (_) {
      // Ignore webview DOM injection failures and keep the checkout visible.
    }
  }

  Future<void> _checkPaymentStatus() async {
    if (_hasCompleted) {
      return;
    }

    try {
      final payment = await context.read<CartService>().getPaymentStatus(
        paymentId: widget.checkout.paymentId,
      );

      if (!mounted || _hasCompleted) {
        return;
      }

      if (payment.status.toUpperCase() == 'SUCCESS') {
        _hasCompleted = true;
        _statusTimer?.cancel();
        Navigator.of(context).pop(true);
      }
    } catch (_) {
      // Ignore transient polling failures and continue polling.
    }
  }
}
