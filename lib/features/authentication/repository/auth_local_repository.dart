import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'auth_local_repository.g.dart';

@Riverpod(keepAlive: true)
AuthLocalRepository authLocalRepository(Ref ref) {
  return AuthLocalRepository();
}

class AuthLocalRepository {
  late final SharedPreferences _sharedPreferences;
  static const String tokenKey = "x-auth-token";

  Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  Future<void> setToken(String? token) async {
    if (token != null) {
      await _sharedPreferences.setString(tokenKey, token);
    }
  }

  String? getToken() {
    return _sharedPreferences.getString(tokenKey);
  }

  Future<bool> removeToken() {
    return _sharedPreferences.remove(tokenKey);
  }
}
