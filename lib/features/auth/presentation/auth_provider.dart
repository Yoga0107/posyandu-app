import 'package:flutter/foundation.dart';
import 'package:posyandu_app/features/auth/data/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../../../core/api/api_client.dart';
import '../../../../core/constants/app_constants.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;

  UserModel? get user      => _user;
  bool get isLoading       => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;
  bool get isRW            => _user?.role == 'rw';
  bool get isKader         => _user?.role == 'kader';
  bool get isWarga         => _user?.role == 'warga';
  bool get isAdminLevel    => _user?.role == 'rw' || _user?.role == 'kader';

  final _api = ApiClient.instance;

  Future<bool> loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token    = prefs.getString(AppConstants.tokenKey);
      final userData = prefs.getString(AppConstants.userKey);
      if (token != null && userData != null) {
        _user = UserModel.fromJson(jsonDecode(userData));
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<bool> login(String identifier, String password) async {
    _setLoading(true); _errorMessage = null;
    try {
      final response = await _api.post('/auth/login', data: {'identifier': identifier, 'password': password});
      final data = response.data['data'];
      _user = UserModel.fromJson(data['user']);
      _isAuthenticated = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.tokenKey,        data['accessToken']);
      await prefs.setString(AppConstants.refreshTokenKey, data['refreshToken']);
      await prefs.setString(AppConstants.userKey,         jsonEncode(_user!.toJson()));
      await prefs.setString(AppConstants.roleKey,         _user!.role);
      notifyListeners(); return true;
    } catch (e) {
      _errorMessage = parseApiError(e); notifyListeners(); return false;
    } finally { _setLoading(false); }
  }

  /// Daftar akun sendiri (self sign-up). Role selalu 'warga' di backend,
  /// akun langsung aktif & otomatis login setelah berhasil.
  Future<bool> register({
    required String nama,
    required String noHp,
    String? email,
    required String password,
  }) async {
    _setLoading(true); _errorMessage = null;
    try {
      final response = await _api.post('/auth/register', data: {
        'nama': nama,
        'no_hp': noHp,
        if (email != null && email.isNotEmpty) 'email': email,
        'password': password,
      });
      final data = response.data['data'];
      _user = UserModel.fromJson(data['user']);
      _isAuthenticated = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.tokenKey,        data['accessToken']);
      await prefs.setString(AppConstants.refreshTokenKey, data['refreshToken']);
      await prefs.setString(AppConstants.userKey,         jsonEncode(_user!.toJson()));
      await prefs.setString(AppConstants.roleKey,         _user!.role);
      notifyListeners(); return true;
    } catch (e) {
      _errorMessage = parseApiError(e); notifyListeners(); return false;
    } finally { _setLoading(false); }
  }

  Future<void> logout() async {
    try { await _api.post('/auth/logout'); } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _user = null; _isAuthenticated = false; notifyListeners();
  }

  Future<void> refreshProfile() async {
    try {
      final r = await _api.get('/auth/me');
      _user = UserModel.fromJson(r.data['data']['user']);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.userKey, jsonEncode(_user!.toJson()));
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> changePassword(String oldPw, String newPw) async {
    _setLoading(true); _errorMessage = null;
    try {
      await _api.put('/auth/change-password', data: {'oldPassword': oldPw, 'newPassword': newPw});
      return true;
    } catch (e) { _errorMessage = parseApiError(e); return false; }
    finally { _setLoading(false); }
  }

  void _setLoading(bool v) { _isLoading = v; notifyListeners(); }
  void clearError() { _errorMessage = null; notifyListeners(); }
}
