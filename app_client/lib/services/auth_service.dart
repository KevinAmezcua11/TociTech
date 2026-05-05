import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  final ApiService api;

  AuthService(this.api);

  Future<User> login(String username, String password) async {
    final response = await api.post(
      '/auth/login',
      {
        "username": username.trim().toLowerCase(),
        "password": password,
      },
    );

    api.token = response['token'];

    return User.fromJson(response['user']);
  }

  Future<User> register({
    required String username,
    required String password,
    required String names,
    required String lastnames,
    required String email,
    required String phone,
  }) async {
    final response = await api.post(
      '/auth/register',
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
}