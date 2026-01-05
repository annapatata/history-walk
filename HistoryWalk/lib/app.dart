import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:historywalk/utils/theme/app_theme.dart';
import 'features/auth/controller/auth_controller.dart';
import 'features/splash/screens/splash_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // Δηλώνουμε τον AuthController ΜΙΑ φορά
    Get.put(AuthController());

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,

      // THEME
      themeMode: ThemeMode.light,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,

      // START SCREEN
      home: const SplashScreen(),
    );
  }
}
