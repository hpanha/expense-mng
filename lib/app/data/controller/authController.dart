import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:extend_system/app/data/services/api_service.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;

/// AuthController supports two login strategies:
///
/// 1. Laravel Auth — email/password → POST /api/register or /api/login
///    → server returns a Laravel API token → stored in GetStorage.
///
/// 2. Firebase Auth (Google / Facebook) → Firebase issues an ID token
///    → POST /api/firebase/login with that ID token
///    → server verifies, creates/finds the user, returns a Laravel API token
///    → stored in GetStorage.
///
/// All protected API calls use the stored Laravel token as Bearer.
/// Firebase tokens are NEVER sent to business endpoints.
class AuthController extends GetxController {
  final ApiService api = ApiService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  RxBool isLoggedIn = false.obs;
  RxBool isLoading = false.obs;
  RxString errorMessage = "".obs;

  Rx<Map<String, dynamic>?> user = Rx<Map<String, dynamic>?>(null);

  @override
  void onInit() {
    super.onInit();
    // Restore session from storage if a Laravel token is already saved
    if (api.isLoggedIn()) {
      isLoggedIn.value = true;
      _loadProfile();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Laravel Email / Password Auth
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> register({
    required String username,
    required String email,
    required String password,
    String? passwordConfirmation,
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

      final response = await api.postForm(
        "register",
        {
          "username": username,
          "email": email,
          "password": password,
          "password_confirmation": passwordConfirmation ?? password,
        },
      );

      final token = _extractToken(response);
      if (token != null) {
        await api.setToken(token);
      }

      user.value = _extractUser(response) ?? {"name": username, "email": email};
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

      final response = await api.postForm(
        "login",
        {"email": email, "password": password},
      );

      final token = _extractToken(response);
      if (token == null) {
        throw Exception('No token received from server');
      }
      await api.setToken(token);

      user.value = _extractUser(response) ?? {"email": email};
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

  // ─────────────────────────────────────────────────────────────────────────
  // Firebase Social Auth → exchange for Laravel token
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      errorMessage.value = "";

      final GoogleSignIn googleSignIn = kIsWeb
          ? GoogleSignIn(
              clientId:
                  '449999885077-ov2m8garmn2fs1ah9qi2gfp5sion5c4b.apps.googleusercontent.com',
            )
          : GoogleSignIn();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) throw Exception('Sign in cancelled by user');

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final firebaseIdToken = await userCredential.user?.getIdToken();

      if (firebaseIdToken == null) {
        throw Exception('Failed to get Firebase ID token');
      }

      // Exchange Firebase token for Laravel API token
      await _exchangeFirebaseToken(
        firebaseIdToken: firebaseIdToken,
        displayName: userCredential.user?.displayName,
        email: userCredential.user?.email,
      );

      Get.snackbar(
        'Success',
        'Logged in with Google!',
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.offAllNamed('/home');
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Google login failed: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithFacebook() async {
    try {
      isLoading.value = true;
      errorMessage.value = "";

      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.cancelled) {
        throw Exception('Login cancelled by user');
      } else if (result.status != LoginStatus.success) {
        throw Exception(result.message ?? 'Facebook login failed');
      }

      final OAuthCredential credential =
          FacebookAuthProvider.credential(result.accessToken!.tokenString);

      final userCredential = await _auth.signInWithCredential(credential);
      final firebaseIdToken = await userCredential.user?.getIdToken();

      if (firebaseIdToken == null) {
        throw Exception('Failed to get Firebase ID token');
      }

      // Exchange Firebase token for Laravel API token
      await _exchangeFirebaseToken(
        firebaseIdToken: firebaseIdToken,
        displayName: userCredential.user?.displayName,
        email: userCredential.user?.email,
      );

      Get.snackbar(
        'Success',
        'Logged in with Facebook!',
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.offAllNamed('/home');
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Facebook login failed: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Sends the Firebase ID token to the backend's /firebase/login endpoint.
  /// The backend verifies the token, creates/finds the user, and returns a
  /// Laravel API token which we then store for all future API calls.
  Future<void> _exchangeFirebaseToken({
    required String firebaseIdToken,
    String? displayName,
    String? email,
  }) async {
    final response = await api.postForm(
      "firebase/login",
      {"idToken": firebaseIdToken},
    );

    final token = _extractToken(response);
    if (token == null) {
      throw Exception('No Laravel token received from firebase/login');
    }
    await api.setToken(token);

    user.value = _extractUser(response) ??
        {
          "name": displayName ?? "User",
          "email": email ?? "",
        };
    isLoggedIn.value = true;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Profile
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _loadProfile() async {
    try {
      await getProfile();
    } catch (e) {
      debugPrint("Could not load profile on init: $e");
    }
  }

  Future<void> getProfile() async {
    try {
      final response = await api.get('profile');
      if (response != null) {
        // Support both { user: {...} } and flat { name, email, ... }
        final userData = response['user'] ?? response;
        if (userData is Map<String, dynamic>) {
          user.value = userData;
        }
      }
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

      final data = <String, dynamic>{};
      if (username != null && username.isNotEmpty) data['name'] = username;
      if (email != null && email.isNotEmpty) data['email'] = email;
      if (password != null && password.isNotEmpty) {
        data['password'] = password;
        data['password_confirmation'] = passwordConfirmation ?? password;
      }

      final response = await api.put('profile', data);
      if (response != null) {
        final userData = response['user'] ?? response;
        if (userData is Map<String, dynamic>) {
          user.value = userData;
        }
      }

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

  // ─────────────────────────────────────────────────────────────────────────
  // Logout
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    try {
      isLoading.value = true;

      // Call backend logout to invalidate the Laravel token
      try {
        await api.postForm("logout", {}, requireAuth: true);
      } catch (e) {
        debugPrint("Backend logout error (ignored): $e");
      }

      // Sign out of Firebase / social providers
      try {
        await _auth.signOut();
        await FacebookAuth.instance.logOut();
        await GoogleSignIn().signOut();
      } catch (e) {
        debugPrint("Firebase signout error (ignored): $e");
      }

      await api.clearToken();
      user.value = null;
      isLoggedIn.value = false;

      Get.snackbar(
        'Success',
        'Logged out successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.offAllNamed('/login');
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

  // ─────────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────────

  /// Extracts the auth token from common Laravel response formats.
  /// Supports: { token }, { access_token }, { data: { token } }
  String? _extractToken(dynamic response) {
    if (response == null) return null;
    if (response is Map) {
      return response['token'] as String? ??
          response['access_token'] as String? ??
          (response['data'] is Map ? response['data']['token'] as String? : null);
    }
    return null;
  }

  /// Extracts the user map from common Laravel response formats.
  /// Supports: { user }, { data: { user } }, flat user fields.
  Map<String, dynamic>? _extractUser(dynamic response) {
    if (response == null) return null;
    if (response is Map<String, dynamic>) {
      if (response.containsKey('user') && response['user'] is Map) {
        return Map<String, dynamic>.from(response['user'] as Map);
      }
      if (response.containsKey('data') && response['data'] is Map) {
        final data = response['data'] as Map;
        if (data.containsKey('user')) {
          return Map<String, dynamic>.from(data['user'] as Map);
        }
      }
      // Flat response with name/email at root
      if (response.containsKey('name') || response.containsKey('email')) {
        return response;
      }
    }
    return null;
  }
}
