import '../models/cart.dart';
import '../models/order.dart';
import '../models/payment_checkout.dart';
import 'api_client.dart';

class CartService {
  final ApiClient _apiClient;

  CartService(this._apiClient);

  Future<Cart> getCart() async {
    final response = await _apiClient.getJson('/cart', authenticated: true);
    return Cart.fromJson(response['cart'] as Map<String, dynamic>);
  }

  Future<Cart> addItem({
    required String productId,
    required int quantity,
  }) async {
    final response = await _apiClient.postJson(
      '/cart/items',
      authenticated: true,
      body: {
        'productId': productId,
        'quantity': quantity,
      },
    );

    return Cart.fromJson(response['cart'] as Map<String, dynamic>);
  }

  Future<Cart> updateItemQuantity({
    required String cartItemId,
    required int quantity,
  }) async {
    final response = await _apiClient.putJson(
      '/cart/items/$cartItemId',
      authenticated: true,
      body: {
        'quantity': quantity,
      },
    );

    return Cart.fromJson(response['cart'] as Map<String, dynamic>);
  }

  Future<Cart> removeItem({
    required String cartItemId,
  }) async {
    final response = await _apiClient.deleteJson(
      '/cart/items/$cartItemId',
      authenticated: true,
    );

    return Cart.fromJson(response['cart'] as Map<String, dynamic>);
  }

  Future<Order> createOrder() async {
    final response = await _apiClient.postEmpty(
      '/orders',
      authenticated: true,
    );

    return Order.fromJson(response['order'] as Map<String, dynamic>);
  }

  Future<PaymentCheckout> createCheckout({
    required double amount,
    required String orderId,
  }) async {
    final response = await _apiClient.postJson(
      '/payments/create-checkout',
      authenticated: true,
      body: {
        'amount': amount,
        'orderId': orderId,
      },
    );

    return PaymentCheckout.fromJson(response);
  }

  Future<PaymentCheckout> getPaymentStatus({
    required String paymentId,
  }) async {
    final response = await _apiClient.getJson(
      '/payments/status/$paymentId',
      authenticated: true,
    );

    return PaymentCheckout.fromJson(response);
  }
}
