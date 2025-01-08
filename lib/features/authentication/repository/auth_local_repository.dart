import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socieaty/features/user/model/socieaty_user.dart';

part 'auth_local_repository.g.dart';

@Riverpod(keepAlive: true)
AuthLocalRepository authLocalRepository(Ref ref) {
  return AuthLocalRepository();
}

class AuthLocalRepository {
  late final SharedPreferences _sharedPreferences;
  static const String tokenKey = "x-auth-token";
  static const String userDataKey = "user";

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
    removeUserData();
    return _sharedPreferences.remove(tokenKey);
  }

  Future<void> setUserData(SocieatyUser user) async {
    await _sharedPreferences.setString(userDataKey, jsonEncode(user.toJson()));
  }

  SocieatyUser? getUserData() {
    final raw = _sharedPreferences.getString(userDataKey);
    if (raw == null || raw.isEmpty) return null;
    return SocieatyUser.fromJson(jsonDecode(raw));
  }

  Future<bool> removeUserData() {
    return _sharedPreferences.remove(userDataKey);
  }
}
