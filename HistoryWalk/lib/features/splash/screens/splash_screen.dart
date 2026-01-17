import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:historywalk/features/auth/controller/auth_controller.dart';


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

    // 1. Manually trigger the initial check immediately
    // This ensures that even if 'ever' doesn't detect a "change",
    // the logic runs for the current state.
    _handleAuthChanged(authController.firebaseUser.value);

    /// Ακούμε το auth state
    ever(authController.firebaseUser, _handleAuthChanged);
  }

  bool _hasNavigated = false;
  void _handleAuthChanged(user) async{
    if(_hasNavigated) return;
    // Μικρό delay για να φανεί το splash
    Future.delayed(const Duration(seconds: 2), () {
      if(_hasNavigated) return;
      _hasNavigated=true;

      authController.checkPersistentLogin();
      
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEB35F),
      body: Center(
        child: Image.asset("assets/logos/history-walk-logo.png", width: 280),
      ),
    );
  }
}
