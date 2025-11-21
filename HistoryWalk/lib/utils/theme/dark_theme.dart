import 'package:flutter/material.dart';
import 'app_colors.dart';

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  fontFamily:'Nunito',
  scaffoldBackgroundColor: AppColors.backgroundDark,
  primaryColor: AppColors.headingDark,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.backgroundDark,
    titleTextStyle: TextStyle(
      color: AppColors.textDark,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    iconTheme: IconThemeData(
      color: AppColors.symbolsDark,
    ),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: AppColors.textDark),
    bodyMedium: TextStyle(color: AppColors.textDark),
    headlineMedium: TextStyle(
      color: AppColors.headingDark,
      fontWeight: FontWeight.bold,
    ),
  ),
  colorScheme: const ColorScheme.dark(
    primary: AppColors.headingDark,
    secondary: AppColors.symbolsDark,
    surface: AppColors.cardsDark,
    onSurface: AppColors.textDark,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.buttonDark,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
  ),
);
