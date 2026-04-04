import 'auth_user.dart';

class ProfileDashboard {
  final AuthUser user;
  final int orderCount;
  final int wishlistCount;
  final int cartCount;

  const ProfileDashboard({
    required this.user,
    required this.orderCount,
    required this.wishlistCount,
    required this.cartCount,
  });

  ProfileDashboard copyWith({
    AuthUser? user,
    int? orderCount,
    int? wishlistCount,
    int? cartCount,
  }) {
    return ProfileDashboard(
      user: user ?? this.user,
      orderCount: orderCount ?? this.orderCount,
      wishlistCount: wishlistCount ?? this.wishlistCount,
      cartCount: cartCount ?? this.cartCount,
    );
  }
}
