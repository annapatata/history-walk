import 'package:flutter/material.dart';

class PassportTheme extends ThemeExtension<PassportTheme> {
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;
  final double borderRadius;
  final double elevation;

  const PassportTheme({
    required this.backgroundColor,
    required this.textColor,
    required this.iconColor,
    required this.borderRadius,
    required this.elevation,
  });

  @override
  PassportTheme copyWith({
    Color? backgroundColor,
    Color? textColor,
    Color? iconColor,
    double? borderRadius,
    double? elevation,
  }) {
    return PassportTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      iconColor: iconColor ?? this.iconColor,
      borderRadius: borderRadius ?? this.borderRadius,
      elevation: elevation ?? this.elevation,
    );
  }

  @override
  PassportTheme lerp(ThemeExtension<PassportTheme>? other, double t) {
    if (other is! PassportTheme) return this;

    return PassportTheme(
      backgroundColor:
          Color.lerp(backgroundColor, other.backgroundColor, t)!,
      textColor: Color.lerp(textColor, other.textColor, t)!,
      iconColor: Color.lerp(iconColor, other.iconColor, t)!,
      borderRadius: borderRadius,
      elevation: elevation,
    );
  }
}