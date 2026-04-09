import 'dart:async';
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
  final Duration timeout;
  String? _accessToken;

  ApiClient({
    this.baseUrl = AppConfig.apiBaseUrl,
    this.timeout = const Duration(seconds: 20),
  });

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
    ).timeout(timeout, onTimeout: _throwTimeout);

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
    ).timeout(timeout, onTimeout: _throwTimeout);

    return _decodeJson(response);
  }

  Future<Map<String, dynamic>> postEmpty(
    String path, {
    bool authenticated = false,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: _buildHeaders(
        authenticated: authenticated,
        includeJsonContentType: false,
      ),
    ).timeout(timeout, onTimeout: _throwTimeout);

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
    ).timeout(timeout, onTimeout: _throwTimeout);

    return _decodeJson(response);
  }

  Future<Map<String, dynamic>> putJson(
    String path, {
    required Map<String, dynamic> body,
    bool authenticated = false,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl$path'),
      headers: _buildHeaders(authenticated: authenticated),
      body: jsonEncode(body),
    ).timeout(timeout, onTimeout: _throwTimeout);

    return _decodeJson(response);
  }

  Future<Map<String, dynamic>> deleteJson(
    String path, {
    bool authenticated = false,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$path'),
      headers: _buildHeaders(
        authenticated: authenticated,
        includeJsonContentType: false,
      ),
    ).timeout(timeout, onTimeout: _throwTimeout);

    return _decodeJson(response);
  }

  Future<Map<String, dynamic>> putMultipart(
    String path, {
    required Map<String, String> fields,
    String? fileField,
    String? filePath,
    bool authenticated = false,
  }) async {
    final request = http.MultipartRequest('PUT', Uri.parse('$baseUrl$path'));
    request.headers.addAll(_buildHeaders(authenticated: authenticated));
    request.fields.addAll(fields);

    if (fileField != null && filePath != null && filePath.isNotEmpty) {
      request.files.add(
        await http.MultipartFile.fromPath(fileField, filePath),
      );
    }

    final streamed = await request.send().timeout(timeout, onTimeout: () {
      throw const ApiException(
        'Request timed out. Please check your connection and try again.',
      );
    });
    final response = await http.Response.fromStream(streamed);
    return _decodeJson(response);
  }

  Future<http.Response> _throwTimeout() {
    throw const ApiException(
      'Request timed out. Please check your connection and try again.',
    );
  }

  Map<String, String> _buildHeaders({
    required bool authenticated,
    bool includeJsonContentType = true,
  }) {
    final headers = <String, String>{'Accept': 'application/json'};

    if (includeJsonContentType) {
      headers['Content-Type'] = 'application/json';
    }

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
