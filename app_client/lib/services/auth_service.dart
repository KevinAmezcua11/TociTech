import '../models/user_model.dart';
import '../database/local/session_local_service.dart';
import 'api_service.dart';

class AuthService {
  final ApiService api = ApiService();

  Future<User> login(
    String username,
    String password,
  ) async {

    final response = await api.post('/auth/login',
      {
        "username": username.trim().toLowerCase(),
        "password": password,
      },
    );

    final token = response['token'];

    api.token = token;

    final user = User.fromJson(response['user']);

    await SessionLocalService.saveSession(user, token,);

    return user;
  }

  Future<User> register({
    required String username,
    required String password,
    required String names,
    required String lastnames,
    required String email,
    required String phone,
  }) async {
    final response = await api.post('/auth/register',
      {
        "username": username.trim().toLowerCase(),
        "password": password,
        "names": names,
        "lastnames": lastnames,
        "email": email,
        "phone": phone,
      },
    );

    return User.fromJson(response);
  }

  Future<Map<String, dynamic>?> getSavedSession() async {
    return await SessionLocalService.getSession();
  }

  Future<void> logout() async {
    api.token = null;
    await SessionLocalService.clearSession();
  }
}
