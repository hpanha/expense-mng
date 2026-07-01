import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:extend_system/app/data/services/api_service.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;

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
    // Listen to Firebase Auth state changes
    _auth.authStateChanges().listen((User? firebaseUser) async {
      if (firebaseUser != null) {
        final idToken = await firebaseUser.getIdToken();
        if (idToken != null) {
          await api.setToken(idToken);
        }
        user.value = {
          'name': firebaseUser.displayName ?? 'User',
          'email': firebaseUser.email ?? '',
        };
        isLoggedIn.value = true;
        // Load additional profile details from backend if synced
        await getProfile();
      } else {
        await api.clearToken();
        user.value = null;
        isLoggedIn.value = false;
      }
    });
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

      // Firebase Registration
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update Display Name
      await credential.user?.updateDisplayName(username);

      final idToken = await credential.user?.getIdToken();
      if (idToken != null) {
        await api.setToken(idToken);
      }

      user.value = {
        'name': username,
        'email': email,
      };
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

      // Firebase Sign In
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final idToken = await credential.user?.getIdToken();
      if (idToken != null) {
        await api.setToken(idToken);
      }

      user.value = {
        'name': credential.user?.displayName ?? 'User',
        'email': credential.user?.email ?? '',
      };
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

  Future<void> signInWithFacebook() async {
    try {
      isLoading.value = true;
      errorMessage.value = "";

      // Trigger Facebook login flow
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        // Create a credential from the access token
        final OAuthCredential credential =
            FacebookAuthProvider.credential(result.accessToken!.tokenString);

        // Sign in to Firebase with the credential
        final userCredential = await _auth.signInWithCredential(credential);

        final idToken = await userCredential.user?.getIdToken();
        if (idToken != null) {
          await api.setToken(idToken);
        }

        user.value = {
          'name': userCredential.user?.displayName ?? 'User',
          'email': userCredential.user?.email ?? '',
        };
        isLoggedIn.value = true;

        Get.snackbar(
          'Success',
          'Logged in with Facebook!',
          snackPosition: SnackPosition.BOTTOM,
        );

        Get.offAllNamed('/home');
      } else if (result.status == LoginStatus.cancelled) {
        throw Exception('Login cancelled by user');
      } else {
        throw Exception(result.message ?? 'Facebook login failed');
      }
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

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      errorMessage.value = "";

      // Trigger the Google Sign-In flow
      final GoogleSignIn googleSignIn = kIsWeb
          ? GoogleSignIn(
              clientId:
                  '449999885077-ov2m8garmn2fs1ah9qi2gfp5sion5c4b.apps.googleusercontent.com', // Replace this with your Web Client ID from Firebase Console
            )
          : GoogleSignIn();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser != null) {
        // Obtain the auth details from the request
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        // Create a new credential
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Sign in to Firebase with the credential
        final userCredential = await _auth.signInWithCredential(credential);

        final idToken = await userCredential.user?.getIdToken();
        if (idToken != null) {
          await api.setToken(idToken);
        }

        user.value = {
          'name': userCredential.user?.displayName ?? 'User',
          'email': userCredential.user?.email ?? '',
        };
        isLoggedIn.value = true;

        Get.snackbar(
          'Success',
          'Logged in with Google!',
          snackPosition: SnackPosition.BOTTOM,
        );

        Get.offAllNamed('/home');
      } else {
        throw Exception('Sign in cancelled by user');
      }
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

  Future<void> getProfile() async {
    try {
      final response = await api.get('profile');
      if (response != null && response['user'] != null) {
        user.value = response['user'];
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

      // Update in Firebase Auth if needed
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        if (username != null && username.length >= 2) {
          await currentUser.updateDisplayName(username);
        }
        if (email != null && email.isNotEmpty) {
          await currentUser.verifyBeforeUpdateEmail(email);
        }
        if (password != null && password.length >= 8) {
          await currentUser.updatePassword(password);
        }
      }

      // Fallback/sync update to custom backend
      final data = <String, dynamic>{};
      if (username != null) data['username'] = username;
      if (email != null) data['email'] = email;
      if (password != null) {
        data['password'] = password;
        data['password_confirmation'] = passwordConfirmation;
      }

      try {
        final response = await api.put('profile', data);
        if (response != null && response['user'] != null) {
          user.value = response['user'];
        }
      } catch (e) {
        // Log backend sync error but do not block UI success if Firebase updated
        debugPrint("Backend profile sync failed: $e");
      }

      // Update local state
      user.value = {
        'name': currentUser?.displayName ?? username ?? 'User',
        'email': currentUser?.email ?? email ?? '',
      };

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
      // Log out of Firebase, Facebook and Google
      await _auth.signOut();
      await FacebookAuth.instance.logOut();
      await GoogleSignIn().signOut();
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
