import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_user.dart';
import '../services/auth_service.dart';

class AuthState extends ChangeNotifier {
  final AuthService _authService;
  static const _accessTokenKey = 'auth.access_token';
  static const _refreshTokenKey = 'auth.refresh_token';
  static const _userKey = 'auth.user';

  AuthUser? _currentUser;
  String? _accessToken;
  String? _refreshToken;
  bool _isRestoring = true;

  AuthState(this._authService);

  AuthUser? get currentUser => _currentUser;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  bool get isRestoring => _isRestoring;
  bool get isAuthenticated => _accessToken != null && _accessToken!.isNotEmpty;

  Future<void> login({required String email, required String password}) async {
    final result = await _authService.login(email: email, password: password);
    _currentUser = result.user;
    _accessToken = result.accessToken;
    _refreshToken = result.refreshToken;
    _isRestoring = false;
    await _persistSession();
    notifyListeners();
  }

  Future<void> restoreSession() async {
    if (!_isRestoring) {
      return;
    }

    final preferences = await SharedPreferences.getInstance();
    _accessToken = preferences.getString(_accessTokenKey);
    _refreshToken = preferences.getString(_refreshTokenKey);

    final rawUser = preferences.getString(_userKey);
    if (rawUser != null && rawUser.isNotEmpty) {
      _currentUser = AuthUser.fromJson(
        jsonDecode(rawUser) as Map<String, dynamic>,
      );
    }

    _authService.setAccessToken(_accessToken);

    try {
      if (_accessToken != null && _accessToken!.isNotEmpty) {
        _currentUser = await _authService.getCurrentUser();
        await _persistSession();
      } else if (_refreshToken != null && _refreshToken!.isNotEmpty) {
        final result = await _authService.refreshSession(
          refreshToken: _refreshToken!,
        );
        _currentUser = result.user;
        _accessToken = result.accessToken;
        _refreshToken = result.refreshToken;
        await _persistSession();
      }
    } catch (_) {
      if (_refreshToken != null && _refreshToken!.isNotEmpty) {
        try {
          final result = await _authService.refreshSession(
            refreshToken: _refreshToken!,
          );
          _currentUser = result.user;
          _accessToken = result.accessToken;
          _refreshToken = result.refreshToken;
          await _persistSession();
        } catch (_) {
          await _clearSession();
        }
      } else {
        await _clearSession();
      }
    } finally {
      _isRestoring = false;
      notifyListeners();
    }
  }

  Future<void> refreshCurrentUser() async {
    if (!isAuthenticated) return;

    _currentUser = await _authService.getCurrentUser();
    await _persistSession();
    notifyListeners();
  }

  Future<void> logout() async {
    await _clearSession();
    _isRestoring = false;
    notifyListeners();
  }

  Future<void> _persistSession() async {
    final preferences = await SharedPreferences.getInstance();

    if (_accessToken != null && _accessToken!.isNotEmpty) {
      await preferences.setString(_accessTokenKey, _accessToken!);
    } else {
      await preferences.remove(_accessTokenKey);
    }

    if (_refreshToken != null && _refreshToken!.isNotEmpty) {
      await preferences.setString(_refreshTokenKey, _refreshToken!);
    } else {
      await preferences.remove(_refreshTokenKey);
    }

    if (_currentUser != null) {
      await preferences.setString(
        _userKey,
        jsonEncode({
          'id': _currentUser!.id,
          'firstName': _currentUser!.firstName,
          'lastName': _currentUser!.lastName,
          'email': _currentUser!.email,
          'phone': _currentUser!.phone,
          'avatarPath': _currentUser!.avatarPath,
        }),
      );
    } else {
      await preferences.remove(_userKey);
    }
  }

  Future<void> _clearSession() async {
    _currentUser = null;
    _accessToken = null;
    _refreshToken = null;
    _authService.setAccessToken(null);

    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_accessTokenKey);
    await preferences.remove(_refreshTokenKey);
    await preferences.remove(_userKey);
  }
}
