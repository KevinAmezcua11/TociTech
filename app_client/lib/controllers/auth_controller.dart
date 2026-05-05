import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthController {
  final AuthService authService;

  bool isLoading = false;
  String? errorMessage;
  User? currentUser;

  AuthController(this.authService);

  Future<bool> login(String username, String password) async {
    try {
      isLoading = true;
      errorMessage = null;

      final user = await authService.login(username, password);

      currentUser = user;

      return true;
    } catch (e) {
      errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
    }
  }

  Future<bool> register({
    required String username,
    required String password,
    required String names,
    required String lastnames,
    required String email,
    required String phone,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;

      await authService.register(
        username: username,
        password: password,
        names: names,
        lastnames: lastnames,
        email: email,
        phone: phone,
      );

      return true;
    } catch (e) {
      errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
    }
  }

  void logout() {
    currentUser = null;
    authService.api.token = null;
  }
}