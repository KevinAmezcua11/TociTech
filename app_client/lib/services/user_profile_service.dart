import '../database/local/session_local_service.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class UserProfileService {
  final ApiService api;

  UserProfileService(this.api);

  Future<User> getMe() async {
    final response = await api.get('/users/me');
    return User.fromJson(response);
  }

  Future<User> updateMe({
    required String username,
    required String names,
    required String lastnames,
    required String email,
    required String phone,
  }) async {
    final response = await api.put('/users/me', {
      'username': username.trim().toLowerCase(),
      'names': names.trim(),
      'lastnames': lastnames.trim(),
      'email': email.trim().toLowerCase(),
      'phone': phone.trim(),
    });

    final user = User.fromJson(response);
    final session = await SessionLocalService.getSession();
    final token = session?['token'] as String?;

    if (token != null) {
      await SessionLocalService.saveSession(user, token);
    }

    return user;
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await api.put('/users/me/password', {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }
}
