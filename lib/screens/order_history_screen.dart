import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../constants/colors.dart';
import '../models/order.dart';
import '../services/account_service.dart';
import '../services/cart_service.dart';
import '../utils/currency_formatter.dart';
import '../widgets/payment_checkout_sheet.dart';
import '../widgets/skeleton_box.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  late Future<List<Order>> _ordersFuture;
  String? _payingOrderId;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _loadOrders();
  }

  Future<List<Order>> _loadOrders() {
    return context.read<AccountService>().getOrders();
  }

  Future<void> _retryPayment(Order order) async {
    setState(() => _payingOrderId = order.id);

    try {
      final cartService = context.read<CartService>();
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
                builder: (_) => PaymentCheckoutSheet(checkout: checkout),
              ) ??
              false;

      if (!mounted) return;

      if (paymentSucceeded) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Payment completed successfully.',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
            ),
          ),
        );
      }

      setState(() {
        _ordersFuture = _loadOrders();
      });
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
        setState(() => _payingOrderId = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: FutureBuilder<List<Order>>(
                future: _ordersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: 4,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) =>
                          const _OrderCardSkeleton(),
                    );
                  }

                  if (snapshot.hasError) {
                    return _buildMessageState(
                      title: 'Unable to load orders',
                      message: snapshot.error.toString(),
                    );
                  }

                  final orders = snapshot.data ?? const [];
                  if (orders.isEmpty) {
                    return _buildMessageState(
                      title: 'No orders yet',
                      message: 'Your order history will show up here.',
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: orders.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _buildOrderCard(orders[index]);
                    },
                  );
                },
              ),
            ),
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
              'Order History',
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

  Widget _buildMessageState({
    required String title,
    required String message,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.receipt_long_outlined,
              size: 42,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.nunito(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
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

  Widget _buildOrderCard(Order order) {
    final isPaying = _payingOrderId == order.id;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEFEFEF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '#${order.id}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _StatusPill(status: order.status),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${order.itemCount} item${order.itemCount == 1 ? '' : 's'}',
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  formatCurrency(order.total),
                  style: GoogleFonts.nunito(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
              if (order.status.toUpperCase() == 'PENDING')
                SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    onPressed: isPaying ? null : () => _retryPayment(order),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          AppColors.primary.withValues(alpha: 0.45),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: isPaying
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'PAY',
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),
            ],
          ),
          if (order.createdAt != null) ...[
            const SizedBox(height: 6),
            Text(
              _formatDate(order.createdAt!),
              style: GoogleFonts.nunito(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}

class _OrderCardSkeleton extends StatelessWidget {
  const _OrderCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEFEFEF)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: SkeletonBox(width: double.infinity, height: 14)),
              SizedBox(width: 12),
              SkeletonBox(width: 72, height: 24, borderRadius: BorderRadius.all(Radius.circular(99))),
            ],
          ),
          SizedBox(height: 10),
          SkeletonBox(width: 72, height: 12),
          SizedBox(height: 8),
          SkeletonBox(width: 124, height: 22),
          SizedBox(height: 8),
          SkeletonBox(width: 112, height: 12),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;

  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final normalized = status.toUpperCase();
    final background = switch (normalized) {
      'PAID' => const Color(0xFFE9F8EF),
      'CANCELLED' => const Color(0xFFFDECEC),
      _ => const Color(0xFFFFF3E8),
    };
    final foreground = switch (normalized) {
      'PAID' => const Color(0xFF1F8A52),
      'CANCELLED' => const Color(0xFFD96B6B),
      _ => const Color(0xFFDB7A18),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        normalized,
        style: GoogleFonts.nunito(
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          color: foreground,
        ),
      ),
    );
  }
}
