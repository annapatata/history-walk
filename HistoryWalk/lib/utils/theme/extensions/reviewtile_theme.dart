import 'package:flutter/material.dart';

class ReviewTileTheme extends ThemeExtension<ReviewTileTheme> {
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;
  final double borderRadius;
  final double elevation;
  final Color starColor;

  const ReviewTileTheme({
    required this.backgroundColor,
    required this.textColor,
    required this.iconColor,
    required this.borderRadius,
    required this.elevation,
    required this.starColor,
  });

  @override
  ReviewTileTheme copyWith({
    Color? backgroundColor,
    Color? textColor,
    Color? iconColor,
    double? borderRadius,
    double? elevation,
    Color? starColor,
  }) {
    return ReviewTileTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      iconColor: iconColor ?? this.iconColor,
      borderRadius: borderRadius ?? this.borderRadius,
      elevation: elevation ?? this.elevation,
      starColor: starColor ?? this.starColor,
    );
  }

  @override
  ReviewTileTheme lerp(ThemeExtension<ReviewTileTheme>? other, double t) {
    if (other is! ReviewTileTheme) return this;

    return ReviewTileTheme(
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