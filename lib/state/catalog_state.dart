import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../models/product.dart';
import '../services/catalog_service.dart';

class CatalogState extends ChangeNotifier {
  final CatalogService _catalogService;

  CatalogState(this._catalogService);

  bool _isLoading = false;
  String? _errorMessage;
  List<Product> _products = const [];
  List<Product> _trendingNow = const [];
  List<Product> _newArrivals = const [];
  List<Product> _popularNearYou = const [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Product> get products => _products;
  List<Product> get trendingNow => _trendingNow;
  List<Product> get newArrivals => _newArrivals;
  List<Product> get popularNearYou => _popularNearYou;

  Future<void> loadInitialData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _catalogService.getTrendingNow(),
        _catalogService.getNewArrivals(),
        _catalogService.getPopularNearYou(),
      ]);

      _products = const [];
      _trendingNow = results[0];
      _newArrivals = results[1];
      _popularNearYou = results[2];
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setFavorite({
    required String productId,
    required bool isFavorite,
  }) {
    Product update(Product product) {
      if (product.id != productId) {
        return product;
      }

      return product.copyWith(isFavorite: isFavorite);
    }

    _products = _products.map(update).toList();
    _trendingNow = _trendingNow.map(update).toList();
    _newArrivals = _newArrivals.map(update).toList();
    _popularNearYou = _popularNearYou.map(update).toList();
    notifyListeners();
  }

  void syncWishlist(Set<String> wishlistProductIds) {
    Product update(Product product) {
      return product.copyWith(
        isFavorite: wishlistProductIds.contains(product.id),
      );
    }

    _products = _products.map(update).toList();
    _trendingNow = _trendingNow.map(update).toList();
    _newArrivals = _newArrivals.map(update).toList();
    _popularNearYou = _popularNearYou.map(update).toList();
    notifyListeners();
  }
}
