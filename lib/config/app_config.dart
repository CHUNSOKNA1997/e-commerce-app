class AppConfig {
  static const String apiBaseUrl = 'http://10.0.2.2:5000/api/v1';

  static String get apiOrigin {
    final uri = Uri.parse(apiBaseUrl);
    return '${uri.scheme}://${uri.host}${uri.hasPort ? ':${uri.port}' : ''}';
  }
}
