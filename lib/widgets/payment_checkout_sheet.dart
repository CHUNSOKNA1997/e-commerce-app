import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../constants/colors.dart';
import '../models/payment_checkout.dart';
import '../services/cart_service.dart';

class PaymentCheckoutSheet extends StatefulWidget {
  final PaymentCheckout checkout;

  const PaymentCheckoutSheet({
    super.key,
    required this.checkout,
  });

  @override
  State<PaymentCheckoutSheet> createState() => _PaymentCheckoutSheetState();
}

class _PaymentCheckoutSheetState extends State<PaymentCheckoutSheet> {
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
