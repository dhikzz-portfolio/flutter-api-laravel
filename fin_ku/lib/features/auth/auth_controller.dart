import 'package:flutter/foundation.dart';

import '../../../core/config/api_config.dart';
import '../../../core/errors/api_exception.dart';
import '../../../core/models/user_model.dart';
import '../../../core/network/api_client.dart';
import 'data/auth_repository.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._repo);

  final AuthRepository _repo;

  AppUser? _user;
  SessionStatus _status = SessionStatus.loading;

  AppUser? get user => _user;
  SessionStatus get status => _status;
  bool get isAuthenticated => _user != null && _status != SessionStatus.loading;

  String? _flashMessage;
  String? get flashMessage => _flashMessage;

  void showFlash(String message) {
    _flashMessage = message;
    notifyListeners();
  }

  void clearFlash() {
    if (_flashMessage != null) {
      _flashMessage = null;
      notifyListeners();
    }
  }

  Future<void> bootstrap() async {
    _status = SessionStatus.loading;
    notifyListeners();

    final session = await _repo.restore();
    _user = session?.user;
    _status = _user == null ? SessionStatus.loggedOut : SessionStatus.loggedIn;
    notifyListeners();
  }

  Future<void> login(String username, String password) async {
    _status = SessionStatus.logging;
    notifyListeners();

    try {
      final session = await _repo.login(username, password);
      await _repo.saveSession(session);
      ApiConfig.setToken(session.token.value);
      _user = session.user;
      _status = SessionStatus.loggedIn;
      _flashMessage = 'Login berhasil. Selamat datang, ${session.user.nama}!';
    } on ApiException {
      _status = SessionStatus.loggedOut;
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    _user = null;
    _status = SessionStatus.loggedOut;
    _flashMessage = 'Logout berhasil.';
    notifyListeners();
  }

  /// Dipanggil saat response 401 dari request apapun. Token lokal ikut
  /// dibersihkan agar sesi kedaluwarsa tidak dicoba ulang saat app dibuka.
  void _onUnauthorized() {
    if (_user == null) return;
    _user = null;
    _status = SessionStatus.loggedOut;
    _flashMessage = 'Sesi berakhir. Silakan login kembali.';
    _repo.clearSession();
    notifyListeners();
  }

  void bindApiClient() {
    ApiClient.onUnauthorized = _onUnauthorized;
  }

  void refreshUser(AppUser user) {
    _user = user;
    notifyListeners();
  }
}

enum SessionStatus { loading, loggedOut, logging, loggedIn }
