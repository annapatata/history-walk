import 'package:flutter/material.dart';
import 'package:historywalk/utils/theme/app_theme.dart';
import '../features/splash/screens/splash_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // THEME
      themeMode: ThemeMode.light,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,

      // HOME SCREEN
      home: const SplashScreen(),
    );
  }
}
