import '../models/auth_user.dart';
import 'api_client.dart';

class LoginResult {
  final AuthUser user;
  final String accessToken;
  final String refreshToken;

  const LoginResult({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });
}

class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  void setAccessToken(String? accessToken) {
    _apiClient.setAccessToken(accessToken);
  }

  Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.postJson(
      '/auth/login',
      body: {'email': email, 'password': password},
    );

    final user = AuthUser.fromJson(response['user'] as Map<String, dynamic>);
    final accessToken = response['accessToken'] as String;
    final refreshToken = response['refreshToken'] as String;
    _apiClient.setAccessToken(accessToken);

    return LoginResult(
      user: user,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    await _apiClient.postJson(
      '/auth/register',
      body: {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
      },
    );
  }

  Future<AuthUser> getCurrentUser() async {
    final response = await _apiClient.getJson('/auth/me', authenticated: true);

    return AuthUser.fromJson(response['user'] as Map<String, dynamic>);
  }

  Future<LoginResult> refreshSession({required String refreshToken}) async {
    final response = await _apiClient.postJson(
      '/auth/refresh',
      body: {'refreshToken': refreshToken},
    );

    final user = AuthUser.fromJson(response['user'] as Map<String, dynamic>);
    final accessToken = response['accessToken'] as String;
    final nextRefreshToken = response['refreshToken'] as String;
    _apiClient.setAccessToken(accessToken);

    return LoginResult(
      user: user,
      accessToken: accessToken,
      refreshToken: nextRefreshToken,
    );
  }
}
