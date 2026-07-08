import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extend_system/app/data/controller/authController.dart';
import 'package:extend_system/app/theme/app_theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final controller = Get.find<AuthController>();
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final RxBool showPassword = false.obs;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (formKey.currentState!.validate()) {
      controller.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: AppTheme.backgroundTeal,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo/Icon Container
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      size: 36,
                      color: AppTheme.primaryTeal,
                    ),
                  ),
                  const SizedBox(height: 28),
                  
                  // App Title
                  Text(
                    'Financial Tracking',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkTeal,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Login to your account to continue',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.darkTeal.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Login Card Container
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E2222) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryTeal.withOpacity(0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Email Input
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: 'Enter your email',
                            prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.primaryTeal),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppTheme.primaryTeal, width: 2),
                            ),
                            filled: true,
                            fillColor: isDark ? const Color(0xFF2D3232) : Colors.grey[50],
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Email is required';
                            }
                            if (!value.contains('@')) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        // Password Input
                        Obx(
                          () => TextFormField(
                            controller: passwordController,
                            obscureText: !showPassword.value,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: 'Enter your password',
                              prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.primaryTeal),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  showPassword.value
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  showPassword.value = !showPassword.value;
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: AppTheme.primaryTeal, width: 2),
                              ),
                              filled: true,
                              fillColor: isDark ? const Color(0xFF2D3232) : Colors.grey[50],
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                  return 'Password is required';
                              }
                              if (value.length < 8) {
                                  return 'Password must be at least 8 characters';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Login Button
                        Obx(
                          () => SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: controller.isLoading.value ? null : _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryTeal,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: controller.isLoading.value
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Login',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Divider row
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey[300])),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'or',
                          style: TextStyle(color: Colors.grey[500], fontSize: 13),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey[300])),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Facebook Sign In
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        controller.signInWithFacebook();
                      },
                      icon: const Icon(
                        Icons.facebook,
                        color: Color(0xFF1877F2),
                        size: 24,
                      ),
                      label: const Text(
                        'Sign in with Facebook',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Google Sign In
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        controller.signInWithGoogle();
                      },
                      icon: ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Colors.blue, Colors.red, Colors.orange, Colors.green],
                        ).createShader(bounds),
                        child: const Text(
                          'G',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      label: const Text(
                        'Sign in with Google',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Register Redirection
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(color: AppTheme.darkTeal.withOpacity(0.7)),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.toNamed('/register');
                        },
                        child: const Text(
                          'Register here',
                          style: TextStyle(
                            color: AppTheme.primaryTeal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
