import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'extensions/route_box_theme.dart';
import 'extensions/searchbar_theme.dart';
import 'extensions/reviewtile_theme.dart';
import 'extensions/passport_theme.dart';

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
        return TextStyle(color: Colors.pink, fontWeight: FontWeight.w400,);       // unselected color
      },
    ),
),
extensions: <ThemeExtension<dynamic>>[
  RouteBoxTheme(
    backgroundColor: AppColors.routeCardDark,
    textColor: AppColors.textDark,
    iconColor: AppColors.symbolsDark,
    borderRadius: 20,
    elevation: 10,
    starColor: AppColors.stars,
  ),
  SearchbarTheme(
    backgroundColor: AppColors.searchBarLight,
    textColor: AppColors.textLight,
    iconColor: AppColors.symbolsLight,
    borderRadius: 12,
    elevation: 10,
  ),
  ReviewTileTheme(
    backgroundColor: AppColors.cardsDark,
    textColor: AppColors.textDark,
    iconColor: AppColors.symbolsDark,
    borderRadius: 20,
    elevation: 10,
    starColor: AppColors.stars,
  ),
  PassportTheme(
    backgroundColor: AppColors.cardsDark,
    textColor: AppColors.textDark,
    iconColor: const Color(0xFFE5B132),
    borderRadius: 12,
    elevation: 10,
  ),
],
);
