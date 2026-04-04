import '../models/cart.dart';
import 'api_client.dart';

class CartService {
  final ApiClient _apiClient;

  CartService(this._apiClient);

  Future<Cart> getCart() async {
    final response = await _apiClient.getJson('/cart', authenticated: true);
    return Cart.fromJson(response['cart'] as Map<String, dynamic>);
  }
}
