import 'package:flutter/foundation.dart';

import '../models/auth_user.dart';
import '../models/profile_dashboard.dart';
import '../services/account_service.dart';

class ProfileState extends ChangeNotifier {
  final AccountService _accountService;

  ProfileState(this._accountService);

  bool _isLoading = false;
  String? _errorMessage;
  ProfileDashboard? _dashboard;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ProfileDashboard? get dashboard => _dashboard;

  Future<void> loadDashboard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _dashboard = await _accountService.getProfileDashboard();
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<AuthUser> updateProfile({
    required String firstName,
    required String lastName,
    required String phone,
    required String avatarPath,
    String? avatarFilePath,
  }) async {
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _accountService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        avatarPath: avatarPath,
        avatarFilePath: avatarFilePath,
      );
      _dashboard = (_dashboard ??
              ProfileDashboard(
                user: user,
                orderCount: 0,
                wishlistCount: 0,
                cartCount: 0,
              ))
          .copyWith(user: user);
      notifyListeners();
      return user;
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      rethrow;
    }
  }

  void clear() {
    _dashboard = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
