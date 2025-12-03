import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  fontFamily: 'Nunito',
  scaffoldBackgroundColor: AppColors.backgroundLight,
  primaryColor: AppColors.headingLight,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.backgroundLight,
    titleTextStyle: TextStyle(
      color: AppColors.textLight,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    iconTheme: IconThemeData(
      color: AppColors.symbolsLight,
    ),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: AppColors.textLight),
    bodyMedium: TextStyle(color: AppColors.textLight),
    headlineMedium: TextStyle(
      color: AppColors.headingLight,
      fontWeight: FontWeight.bold,
    ),
  ),

  colorScheme: const ColorScheme.light(
    primary: AppColors.headingLight,
    secondary: AppColors.symbolsLight,
    surface: AppColors.cardsLight,
    onSurface: AppColors.textLight,
    secondaryContainer: AppColors.menuBarLight,
    onSecondaryContainer: Colors.transparent, // stop M3 forcing white icons
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.buttonLight,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
  ),

  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: AppColors.menuBarLight,
    indicatorColor: Colors.transparent,
    iconTheme: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return IconThemeData(color: AppColors.symbolsLight); // selected
      }
        return IconThemeData(color: AppColors.textDark);   // unselected
    }),
    labelTextStyle: WidgetStateProperty.resolveWith(
      (states) {
      if (states.contains(WidgetState.selected)) {
        return TextStyle(color: AppColors.symbolsLight, fontWeight: FontWeight.w600,);   // selected color
      }
        return TextStyle(color: Colors.white, fontWeight: FontWeight.w400,);       // unselected color
      },
    ),
),
);
