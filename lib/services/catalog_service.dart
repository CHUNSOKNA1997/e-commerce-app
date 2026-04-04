import '../models/product.dart';
import 'api_client.dart';

class CatalogService {
  final ApiClient _apiClient;

  CatalogService(this._apiClient);

  Future<List<Product>> _getProductList(String path) async {
    final response = await _apiClient.getJson(path);
    final items = response['items'] as List<dynamic>? ?? const [];

    return items
        .map((item) => Product.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Product> getProductById(String productId) async {
    final response = await _apiClient.getJson('/products/$productId');

    return Product.fromJson(response['item'] as Map<String, dynamic>);
  }

  Future<List<Product>> getTrendingNow() async {
    return _getProductList('/products/trending-now');
  }

  Future<List<Product>> getNewArrivals() async {
    return _getProductList('/products/new-arrivals');
  }

  Future<List<Product>> getPopularNearYou() async {
    return _getProductList('/products/popular-near-you');
  }
}
