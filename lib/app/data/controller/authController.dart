import 'package:get/get.dart';
import 'package:extend_system/app/data/services/api_service.dart';

class AuthController extends GetxController {
  final ApiService api = ApiService();

  RxBool isLoggedIn = false.obs;
  RxBool isLoading = false.obs;
  RxString errorMessage = "".obs;

  Rx<Map<String, dynamic>?> user = Rx<Map<String, dynamic>?>(null);

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  void checkLoginStatus() {
    isLoggedIn.value = api.isLoggedIn();
    if (isLoggedIn.value) {
      getProfile();
    }
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = "";

      if (username.length < 2) {
        throw Exception('Username must be at least 2 characters');
      }

      if (password.length < 8) {
        throw Exception('Password must be at least 8 characters');
      }

      final response = await api.post('register', {
        'username': username,
        'email': email,
        'password': password,
      }, requireAuth: false);

      await api.setToken(response['token']);
      user.value = response['user'];
      isLoggedIn.value = true;

      Get.snackbar(
        'Success',
        'Registration successful!',
        snackPosition: SnackPosition.BOTTOM,
      );

      Get.offAllNamed('/home');
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Registration failed: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login({required String email, required String password}) async {
    try {
      isLoading.value = true;
      errorMessage.value = "";

      final response = await api.post('login', {
        'email': email,
        'password': password,
      }, requireAuth: false);

      await api.setToken(response['token']);
      user.value = response['user'];
      isLoggedIn.value = true;

      Get.snackbar(
        'Success',
        'Login successful!',
        snackPosition: SnackPosition.BOTTOM,
      );

      Get.offAllNamed('/home');
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Login failed: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getProfile() async {
    try {
      final response = await api.get('profile');
      user.value = response['user'];
    } catch (e) {
      errorMessage.value = e.toString();
    }
  }

  Future<void> updateProfile({
    String? username,
    String? email,
    String? password,
    String? passwordConfirmation,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = "";

      if (username != null && username.length < 2) {
        throw Exception('Username must be at least 2 characters');
      }

      if (password != null && password.length < 8) {
        throw Exception('Password must be at least 8 characters');
      }

      final data = <String, dynamic>{};
      if (username != null) data['username'] = username;
      if (email != null) data['email'] = email;
      if (password != null) {
        data['password'] = password;
        data['password_confirmation'] = passwordConfirmation;
      }

      final response = await api.put('profile', data);
      user.value = response['user'];

      Get.snackbar(
        'Success',
        'Profile updated successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Update failed: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      await api.post('logout', {});
      await api.clearToken();
      user.value = null;
      isLoggedIn.value = false;

      Get.snackbar(
        'Success',
        'Logged out successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Logout failed: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
