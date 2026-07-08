import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extend_system/app/data/controller/authController.dart';
import 'package:extend_system/app/theme/app_theme.dart';

class RegisterPage extends GetView<AuthController> {
  RegisterPage({super.key});

  final formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final showPassword = false.obs;

  void _submitForm() {
    if (formKey.currentState!.validate()) {
      controller.register(
        username: usernameController.text.trim(),
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
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: Colors.transparent,
        foregroundColor: AppTheme.darkTeal,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo/Icon Container
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_add_rounded,
                      size: 40,
                      color: AppTheme.primaryTeal,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Title text
                  Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkTeal,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Register to start tracking your finances',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.darkTeal.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Registration Card Container
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
                        // Username Field
                        TextFormField(
                          controller: usernameController,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            hintText: 'Enter username (min 2 characters)',
                            prefixIcon: const Icon(Icons.person_outline, color: AppTheme.primaryTeal),
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
                              return 'Username is required';
                            }
                            if (value.length < 2) {
                              return 'Username must be at least 2 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Email Field
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
                        const SizedBox(height: 16),

                        // Password Field
                        Obx(
                          () => TextFormField(
                            controller: passwordController,
                            obscureText: !showPassword.value,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: 'Enter your password (min 8 characters)',
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

                        // Register Submit Button
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
                                      'Register',
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

                  // Redirect to Login page
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: TextStyle(color: AppTheme.darkTeal.withOpacity(0.7)),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.back();
                        },
                        child: const Text(
                          'Login here',
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
