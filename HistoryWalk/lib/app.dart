import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:historywalk/utils/theme/app_theme.dart';
import 'features/splash/screens/splash_screen.dart';
import '../features/auth/controller/auth_controller.dart';
import '../features/auth/controller/login_controller.dart';
import '../features/profile/controller/profile_controller.dart';
import 'package:get_storage/get_storage.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {

    // Initialize AuthController PERMANENTLY so it never dies
    Get.put(AuthController(), permanent: true);
    Get.put(LoginController(),permanent:true);
    Get.put(ProfileController(),permanent:true);

  final box = GetStorage();
  bool isDark = box.read('isDarkMode') ?? false;
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,

      // THEME
      themeMode:ThemeMode.light,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,

      // START SCREEN
      home: const SplashScreen(),
    );
  }
}
