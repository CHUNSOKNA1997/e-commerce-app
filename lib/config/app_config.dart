class AppConfig {
  static const String apiBaseUrl =
      'https://flutter-ecommerce-api.onrender.com/api/v1';

  static String get apiOrigin {
    final uri = Uri.parse(apiBaseUrl);
    return '${uri.scheme}://${uri.host}${uri.hasPort ? ':${uri.port}' : ''}';
  }
}
