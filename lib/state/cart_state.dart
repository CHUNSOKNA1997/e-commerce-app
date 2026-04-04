import 'package:flutter/foundation.dart';

import '../models/cart.dart';
import '../models/order.dart';
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

  Future<void> addItem({
    required String productId,
    required int quantity,
  }) async {
    _errorMessage = null;
    notifyListeners();

    try {
      _cart = await _cartService.addItem(
        productId: productId,
        quantity: quantity,
      );
      notifyListeners();
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateItemQuantity({
    required String cartItemId,
    required int quantity,
  }) async {
    _errorMessage = null;
    notifyListeners();

    try {
      _cart = await _cartService.updateItemQuantity(
        cartItemId: cartItemId,
        quantity: quantity,
      );
      notifyListeners();
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> removeItem({
    required String cartItemId,
  }) async {
    _errorMessage = null;
    notifyListeners();

    try {
      _cart = await _cartService.removeItem(cartItemId: cartItemId);
      notifyListeners();
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<Order> createOrder() async {
    _errorMessage = null;
    notifyListeners();

    try {
      final order = await _cartService.createOrder();
      _cart = Cart(
        id: _cart?.id ?? '',
        items: const [],
        summary: const CartSummary(
          subTotal: 0,
          vat: 0,
          deliveryFee: 0,
          total: 0,
        ),
      );
      notifyListeners();
      return order;
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      rethrow;
    }
  }

  void clear() {
    _isLoading = false;
    _errorMessage = null;
    _cart = null;
    notifyListeners();
  }
}
