import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthState {
  final bool isLoggedIn;
  final bool isRequestingOtp;
  final String phone;
  final String otpHint;

  const AuthState({
    this.isLoggedIn = false,
    this.isRequestingOtp = false,
    this.phone = '',
    this.otpHint = '',
  });

  AuthState copyWith({
    bool? isLoggedIn,
    bool? isRequestingOtp,
    String? phone,
    String? otpHint,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isRequestingOtp: isRequestingOtp ?? this.isRequestingOtp,
      phone: phone ?? this.phone,
      otpHint: otpHint ?? this.otpHint,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  static const _key = 'logged_in';

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final logged = prefs.getBool(_key) ?? false;
    state = state.copyWith(isLoggedIn: logged);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, false);
    state = state.copyWith(isLoggedIn: false);
  }

  /// Demo: pretend to send OTP 123456
  Future<void> requestOtp(String phone) async {
    state = state.copyWith(isRequestingOtp: true, phone: phone);
    await Future.delayed(const Duration(milliseconds: 900));
    state = state.copyWith(isRequestingOtp: false, otpHint: '123456');
  }

  /// Demo verify: accept only 123456
  Future<bool> verifyOtp(String code) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final ok = code.trim() == '123456';
    if (ok) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key, true);
      state = state.copyWith(isLoggedIn: true);
    }
    return ok;
  }

  /// Used by Settings page to clear the displayed hint
  void clearOtpHint() {
    state = state.copyWith(otpHint: '');
  }
}

final authProvider =
StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier());
