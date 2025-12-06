import 'package:flutter/material.dart';

class RouteBoxTheme extends ThemeExtension<RouteBoxTheme> {
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;
  final double borderRadius;
  final double elevation;
  final Color starColor;

  const RouteBoxTheme({
    required this.backgroundColor,
    required this.textColor,
    required this.iconColor,
    required this.borderRadius,
    required this.elevation,
    required this.starColor,
  });

  @override
  RouteBoxTheme copyWith({
    Color? backgroundColor,
    Color? textColor,
    Color? iconColor,
    double? borderRadius,
    double? elevation,
    Color? starColor,
  }) {
    return RouteBoxTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      iconColor: iconColor ?? this.iconColor,
      borderRadius: borderRadius ?? this.borderRadius,
      elevation: elevation ?? this.elevation,
      starColor: starColor ?? this.starColor,
    );
  }

  @override
  RouteBoxTheme lerp(ThemeExtension<RouteBoxTheme>? other, double t) {
    if (other is! RouteBoxTheme) return this;

    return RouteBoxTheme(
      backgroundColor:
          Color.lerp(backgroundColor, other.backgroundColor, t)!,
      textColor: Color.lerp(textColor, other.textColor, t)!,
      iconColor: Color.lerp(iconColor, other.iconColor, t)!,
      borderRadius: borderRadius,
      elevation: elevation,
      starColor: Color.lerp(starColor, other.starColor, t)!,
    );
  }
}
