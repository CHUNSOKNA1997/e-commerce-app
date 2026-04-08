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

class RegisterResult {
  final String message;
  final AuthUser user;
  final int expiresInMinutes;

  const RegisterResult({
    required this.message,
    required this.user,
    required this.expiresInMinutes,
  });
}

class ForgotPasswordOtpVerifyResult {
  final String message;
  final String resetToken;

  const ForgotPasswordOtpVerifyResult({
    required this.message,
    required this.resetToken,
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

  Future<RegisterResult> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final response = await _apiClient.postJson(
      '/auth/register',
      body: {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
      },
    );

    return RegisterResult(
      message: response['message'] as String,
      user: AuthUser.fromJson(response['user'] as Map<String, dynamic>),
      expiresInMinutes: response['expiresInMinutes'] as int? ?? 10,
    );
  }

  Future<void> verifyEmail({
    required String email,
    required String otp,
  }) async {
    await _apiClient.postJson(
      '/auth/verify-email',
      body: {
        'email': email,
        'otp': otp,
      },
    );
  }

  Future<void> forgotPassword({required String email}) async {
    await _apiClient.postJson(
      '/auth/forgot-password',
      body: {
        'email': email,
      },
    );
  }

  Future<ForgotPasswordOtpVerifyResult> verifyForgotPasswordOtp({
    required String email,
    required String otp,
  }) async {
    final response = await _apiClient.postJson(
      '/auth/forgot-password/otp-verify',
      body: {
        'email': email,
        'otp': otp,
      },
    );

    return ForgotPasswordOtpVerifyResult(
      message: response['message'] as String? ?? 'OTP verified.',
      resetToken: response['resetToken'] as String,
    );
  }

  Future<void> resetPassword({
    required String resetToken,
    required String password,
    required String confirmPassword,
  }) async {
    await _apiClient.postJson(
      '/auth/reset-password',
      body: {
        'resetToken': resetToken,
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
