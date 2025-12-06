import 'package:flutter/material.dart';

class SearchbarTheme extends ThemeExtension<SearchbarTheme> {
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;
  final double borderRadius;
  final double elevation;

  const SearchbarTheme({
    required this.backgroundColor,
    required this.textColor,
    required this.iconColor,
    required this.borderRadius,
    required this.elevation,
  });

  @override
  SearchbarTheme copyWith({
    Color? backgroundColor,
    Color? textColor,
    Color? iconColor,
    double? borderRadius,
    double? elevation,
  }) {
    return SearchbarTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      iconColor: iconColor ?? this.iconColor,
      borderRadius: borderRadius ?? this.borderRadius,
      elevation: elevation ?? this.elevation,
    );
  }

  @override
  SearchbarTheme lerp(ThemeExtension<SearchbarTheme>? other, double t) {
    if (other is! SearchbarTheme) return this;

    return SearchbarTheme(
      backgroundColor:
          Color.lerp(backgroundColor, other.backgroundColor, t)!,
      textColor: Color.lerp(textColor, other.textColor, t)!,
      iconColor: Color.lerp(iconColor, other.iconColor, t)!,
      borderRadius: borderRadius,
      elevation: elevation,
    );
  }
}