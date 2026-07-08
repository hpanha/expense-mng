import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:extend_system/firebase_options.dart';

import 'package:extend_system/app/modules/layout.dart';
import 'package:extend_system/app/modules/login.dart';
import 'package:extend_system/app/modules/register.dart';
import 'package:extend_system/app/modules/profile.dart';
import 'package:extend_system/app/modules/splash_screen.dart';
import 'package:extend_system/app/data/controller/authController.dart';
import 'package:extend_system/app/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await GetStorage.init();
  Get.put(AuthController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Financial Tracking',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => RegisterPage(),
        '/profile': (context) => const ProfilePage(),
        '/home': (context) => const HomeShell(),
      },
    );
  }
}

class HomeSelector extends StatelessWidget {
  const HomeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final authController = Get.find<AuthController>();
      return authController.isLoggedIn.value
          ? const HomeShell()
          : const LoginPage();
    });
  }
}
