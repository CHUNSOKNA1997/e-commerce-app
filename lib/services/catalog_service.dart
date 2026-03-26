import '../models/category.dart';
import '../models/product.dart';
import 'api_client.dart';

class CatalogService {
  final ApiClient _apiClient;

  CatalogService(this._apiClient);

  Future<List<Product>> getProducts({String? category}) async {
    final query = category == null || category.isEmpty
        ? ''
        : '?category=${Uri.encodeQueryComponent(category)}';
    final response = await _apiClient.getJson('/products$query');
    final items = response['items'] as List<dynamic>? ?? const [];

    return items
        .map((item) => Product.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<Category>> getCategories() async {
    final response = await _apiClient.getJson('/categories');
    final items = response['items'] as List<dynamic>? ?? const [];

    return items
        .map((item) => Category.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Product> getProductById(String productId) async {
    final response = await _apiClient.getJson('/products/$productId');

    return Product.fromJson(response['item'] as Map<String, dynamic>);
  }
}
