import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../models/category.dart';
import '../models/product.dart';
import '../services/catalog_service.dart';

class CatalogState extends ChangeNotifier {
  final CatalogService _catalogService;

  CatalogState(this._catalogService);

  bool _isLoading = false;
  String? _errorMessage;
  List<Category> _categories = const [];
  List<Product> _products = const [];
  List<Product> _trendingNow = const [];
  List<Product> _newArrivals = const [];
  List<Product> _popularNearYou = const [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Category> get categories => _categories;
  List<Product> get products => _products;
  List<Product> get trendingNow => _trendingNow;
  List<Product> get newArrivals => _newArrivals;
  List<Product> get popularNearYou => _popularNearYou;

  Future<void> loadInitialData({String? category}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _catalogService.getCategories(),
        _catalogService.getProducts(category: category),
        _catalogService.getTrendingNow(),
        _catalogService.getNewArrivals(),
        _catalogService.getPopularNearYou(),
      ]);

      _categories = results[0] as List<Category>;
      _products = results[1] as List<Product>;
      _trendingNow = results[2] as List<Product>;
      _newArrivals = results[3] as List<Product>;
      _popularNearYou = results[4] as List<Product>;
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadProductsByCategory(String? category) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await _catalogService.getProducts(category: category);
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
