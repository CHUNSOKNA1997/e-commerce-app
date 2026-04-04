import '../models/auth_user.dart';
import '../models/order.dart';
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

  Future<AuthUser> updateProfile({
    required String firstName,
    required String lastName,
    required String phone,
    required String avatarPath,
    String? avatarFilePath,
  }) async {
    if (avatarFilePath != null && avatarFilePath.isNotEmpty) {
      await _apiClient.putMultipart(
        '/users/profile',
        authenticated: true,
        fields: {
          'firstName': firstName,
          'lastName': lastName,
          if (phone.isNotEmpty) 'phone': phone,
          if (avatarPath.isNotEmpty) 'avatarPath': avatarPath,
        },
        fileField: 'avatar',
        filePath: avatarFilePath,
      );
    } else {
      await _apiClient.putJson(
        '/users/profile',
        authenticated: true,
        body: {
          'firstName': firstName,
          'lastName': lastName,
          'phone': phone,
          'avatarPath': avatarPath,
        },
      );
    }

    final response = await _apiClient.getJson(
      '/users/profile',
      authenticated: true,
    );
    return AuthUser.fromJson(response['user'] as Map<String, dynamic>);
  }

  Future<List<Order>> getOrders() async {
    final response = await _apiClient.getJson('/orders', authenticated: true);
    final items = response['items'] as List<dynamic>? ?? const [];
    return items
        .map((item) => Order.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
