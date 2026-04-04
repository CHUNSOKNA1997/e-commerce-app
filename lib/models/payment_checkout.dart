import '../config/app_config.dart';

class PaymentCheckout {
  final String paymentId;
  final String orderId;
  final String transactionId;
  final double amount;
  final String currency;
  final String status;
  final String checkoutUrl;
  final String purchaseUrl;
  final DateTime? expiresAt;

  const PaymentCheckout({
    required this.paymentId,
    required this.orderId,
    required this.transactionId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.checkoutUrl,
    required this.purchaseUrl,
    this.expiresAt,
  });

  factory PaymentCheckout.fromJson(Map<String, dynamic> json) {
    final payment = json['payment'] as Map<String, dynamic>? ?? const {};

    return PaymentCheckout(
      paymentId: payment['id'] as String? ?? '',
      orderId: payment['orderId'] as String? ?? '',
      transactionId: payment['tranId'] as String? ?? '',
      amount: ((payment['amount'] ?? 0) as num).toDouble(),
      currency: payment['currency'] as String? ?? 'USD',
      status: payment['status'] as String? ?? 'PENDING',
      checkoutUrl: json['checkout_url'] as String? ?? '',
      purchaseUrl: json['purchase_url'] as String? ?? '',
      expiresAt: DateTime.tryParse(json['expires_at'] as String? ?? ''),
    );
  }

  String get resolvedCheckoutUrl {
    final raw = checkoutUrl.trim();
    if (raw.isEmpty) {
      return raw;
    }

    final uri = Uri.tryParse(raw);
    if (uri == null) {
      return raw;
    }

    if (uri.host == 'localhost' || uri.host == '127.0.0.1') {
      final apiOrigin = Uri.parse(AppConfig.apiOrigin);
      return uri.replace(
        scheme: apiOrigin.scheme,
        host: apiOrigin.host,
        port: apiOrigin.hasPort ? apiOrigin.port : null,
      ).toString();
    }

    return raw;
  }
}
