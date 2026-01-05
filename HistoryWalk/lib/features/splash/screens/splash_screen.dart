import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:historywalk/features/auth/controller/auth_controller.dart';
import 'package:historywalk/features/auth/screens/login/login_screen.dart';
import 'package:historywalk/navigation_menu.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthController authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();

    /// Ακούμε το auth state
    ever(authController.firebaseUser, _handleAuthChanged);
  }

  void _handleAuthChanged(user) {
    // Μικρό delay για να φανεί το splash
    Future.delayed(const Duration(seconds: 2), () {
      if (user == null) {
        // NOT logged in → Login
        Get.offAll(() => const LoginScreen());
      } else {
        // Logged in → App
        Get.offAll(() => const NavigationMenu());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEB35F),
      body: Center(
        child: Image.asset(
          "assets/logos/history-walk-logo.png",
          width: 280,
        ),
      ),
    );
  }
}
