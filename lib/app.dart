import 'package:flutter/material.dart';
import 'package:HistoryWalk/utils/theme/app_theme.dart';
import 'navigation_menu.dart';

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
      home: const NavigationMenu(),
    );
  }
}
