import 'package:flutter/foundation.dart';

import '../models/cart.dart';
import '../services/cart_service.dart';

class CartState extends ChangeNotifier {
  final CartService _cartService;

  CartState(this._cartService);

  bool _isLoading = false;
  String? _errorMessage;
  Cart? _cart;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Cart? get cart => _cart;
  List<CartItem> get items => _cart?.items ?? const [];
  CartSummary get summary => _cart?.summary ?? const CartSummary(
    subTotal: 0,
    vat: 0,
    deliveryFee: 0,
    total: 0,
  );

  Future<void> loadCart() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _cart = await _cartService.getCart();
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _isLoading = false;
    _errorMessage = null;
    _cart = null;
    notifyListeners();
  }
}
