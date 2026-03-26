import '../models/auth_user.dart';
import '../models/profile_dashboard.dart';
import 'api_client.dart';

class AccountService {
  final ApiClient _apiClient;

  AccountService(this._apiClient);

  Future<ProfileDashboard> getProfileDashboard() async {
    final responses = await Future.wait([
      _apiClient.getJson('/users/profile', authenticated: true),
      _apiClient.getJson('/wishlist', authenticated: true),
      _apiClient.getJson('/orders', authenticated: true),
      _apiClient.getJson('/cart', authenticated: true),
    ]);

    final userResponse = responses[0];
    final wishlistResponse = responses[1];
    final ordersResponse = responses[2];
    final cartResponse = responses[3];

    final user = AuthUser.fromJson(
      userResponse['user'] as Map<String, dynamic>,
    );
    final wishlist = wishlistResponse['wishlist'] as Map<String, dynamic>;
    final orders = ordersResponse['items'] as List<dynamic>? ?? const [];
    final cart = cartResponse['cart'] as Map<String, dynamic>;
    final cartItems = cart['items'] as List<dynamic>? ?? const [];
    final wishlistItems = wishlist['items'] as List<dynamic>? ?? const [];

    return ProfileDashboard(
      user: user,
      orderCount: orders.length,
      wishlistCount: wishlistItems.length,
      cartCount: cartItems.length,
    );
  }
}
