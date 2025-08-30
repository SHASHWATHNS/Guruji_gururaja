import '../../auth/data/auth_api.dart';
import 'entities/auth_session.dart';

class AuthRepository {
  final AuthApi api;
  AuthRepository(this.api);

  Future<AuthSession> register({
    required String name,
    required String phone,
    required String password,
    required String email, // <-- required
  }) async {
    final res = await api.register(
      name: name,
      phone: phone,
      password: password,
      email: email, // <-- always send
    );
    return AuthSession(
      success: res.success,
      message: res.message,
      token: res.token,
      userRaw: res.userRaw,
    );
  }

  Future<AuthSession> login({
    required String phone,
    required String password,
  }) async {
    final res = await api.login(phone: phone, password: password);
    return AuthSession(
      success: res.success,
      message: res.message,
      token: res.token,
      userRaw: res.userRaw,
    );
  }
}
