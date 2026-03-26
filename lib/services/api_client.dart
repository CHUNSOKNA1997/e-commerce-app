import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiClient {
  final String baseUrl;
  String? _accessToken;

  ApiClient({this.baseUrl = AppConfig.apiBaseUrl});

  void setAccessToken(String? accessToken) {
    _accessToken = accessToken;
  }

  Future<Map<String, dynamic>> getJson(
    String path, {
    bool authenticated = false,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl$path'),
      headers: _buildHeaders(authenticated: authenticated),
    );

    return _decodeJson(response);
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    required Map<String, dynamic> body,
    bool authenticated = false,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: _buildHeaders(authenticated: authenticated),
      body: jsonEncode(body),
    );

    return _decodeJson(response);
  }

  Future<Map<String, dynamic>> patchJson(
    String path, {
    required Map<String, dynamic> body,
    bool authenticated = false,
  }) async {
    final response = await http.patch(
      Uri.parse('$baseUrl$path'),
      headers: _buildHeaders(authenticated: authenticated),
      body: jsonEncode(body),
    );

    return _decodeJson(response);
  }

  Map<String, String> _buildHeaders({required bool authenticated}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (authenticated && _accessToken != null && _accessToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }

    return headers;
  }

  Map<String, dynamic> _decodeJson(http.Response response) {
    final rawBody = response.body.trim();
    final decoded = rawBody.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(rawBody) as Map<String, dynamic>;

    if (response.statusCode >= 400) {
      throw ApiException(
        decoded['message'] as String? ?? 'Request failed',
        statusCode: response.statusCode,
      );
    }

    return decoded;
  }
}
