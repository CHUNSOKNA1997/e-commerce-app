import 'package:flutter/foundation.dart';

import '../models/auth_user.dart';
import '../services/auth_service.dart';

class AuthState extends ChangeNotifier {
  final AuthService _authService;

  AuthUser? _currentUser;
  String? _accessToken;
  String? _refreshToken;

  AuthState(this._authService);

  AuthUser? get currentUser => _currentUser;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  bool get isAuthenticated => _accessToken != null && _accessToken!.isNotEmpty;

  Future<void> login({required String email, required String password}) async {
    final result = await _authService.login(email: email, password: password);
    _currentUser = result.user;
    _accessToken = result.accessToken;
    _refreshToken = result.refreshToken;
    notifyListeners();
  }

  Future<void> refreshCurrentUser() async {
    if (!isAuthenticated) return;

    _currentUser = await _authService.getCurrentUser();
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _accessToken = null;
    _refreshToken = null;
    notifyListeners();
  }
}
