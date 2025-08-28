import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../auth/data/auth_api.dart';
import '../../../auth/domain/auth_repository.dart';
import '../../../auth/domain/entities/auth_session.dart';

class AuthState {
  final bool isLoggedIn;
  final bool isLoading;
  final String? token;
  final Map<String, dynamic>? user;

  const AuthState({
    this.isLoggedIn = false,
    this.isLoading = false,
    this.token,
    this.user,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    bool? isLoading,
    String? token,
    Map<String, dynamic>? user,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isLoading: isLoading ?? this.isLoading,
      token: token ?? this.token,
      user: user ?? this.user,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repo) : super(const AuthState());
  final AuthRepository _repo;

  static const _kLoggedIn = 'logged_in';
  static const _kToken = 'auth_token';
  static const _kUser = 'auth_user';

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final logged = prefs.getBool(_kLoggedIn) ?? false;
    final token = prefs.getString(_kToken);
    final userS = prefs.getString(_kUser);
    Map<String, dynamic>? user;
    if (userS != null && userS.isNotEmpty) {
      try { user = Map<String, dynamic>.from(jsonDecode(userS)); } catch (_) {}
    }
    state = state.copyWith(isLoggedIn: logged, token: token, user: user);
  }

  Future<AuthSession> register({
    required String name,
    required String phone,
    required String password,
    required String email, // <-- required
  }) async {
    state = state.copyWith(isLoading: true);
    final res = await _repo.register(
      name: name,
      phone: phone,
      password: password,
      email: email, // <-- pass through
    );
    await _handleAuthResult(res);
    return res;
  }

  Future<AuthSession> login({
    required String phone,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true);
    final res = await _repo.login(phone: phone, password: password);
    await _handleAuthResult(res);
    return res;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kLoggedIn);
    await prefs.remove(_kToken);
    await prefs.remove(_kUser);
    state = const AuthState(isLoggedIn: false);
  }

  Future<void> _handleAuthResult(AuthSession res) async {
    state = state.copyWith(isLoading: false);
    if (!res.success) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kLoggedIn, true);
    if (res.token != null && res.token!.isNotEmpty) {
      await prefs.setString(_kToken, res.token!);
    }
    if (res.userRaw != null) {
      await prefs.setString(_kUser, jsonEncode(res.userRaw));
    }
    state = state.copyWith(isLoggedIn: true, token: res.token, user: res.userRaw);
  }
}

/// DI graph
final _apiProvider = Provider<AuthApi>((ref) => const AuthApi());
final _repoProvider = Provider<AuthRepository>((ref) => AuthRepository(ref.read(_apiProvider)));
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier(ref.read(_repoProvider)));
