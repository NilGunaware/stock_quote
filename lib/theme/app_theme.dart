import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF1E1E1E);
  static const Color accentColor = Color(0xFF2196F3);
  static const Color cardColor = Color(0xFF2D2D2D);
  static const Color textColor = Colors.white;
  static const Color subtitleColor = Color(0xFFB3B3B3);
  static const Color positiveColor = Color(0xFF4CAF50);
  static const Color negativeColor = Color(0xFFE53935);
  
  static ThemeData darkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: primaryColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: textColor,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: CardTheme(
      color: cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      hintStyle: TextStyle(color: subtitleColor),
      prefixIconColor: subtitleColor,
    ),
  );

  static BoxDecoration stockItemDecoration = BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(12),
  );

  static TextStyle symbolStyle = const TextStyle(
    color: textColor,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static TextStyle companyNameStyle = TextStyle(
    color: subtitleColor,
    fontSize: 14,
  );

  static TextStyle priceStyle = const TextStyle(
    color: textColor,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static BoxDecoration percentageDecoration(bool isPositive) => BoxDecoration(
    color: (isPositive ? positiveColor : negativeColor).withOpacity(0.15),
    borderRadius: BorderRadius.circular(6),
  );

  static TextStyle percentageStyle(bool isPositive) => TextStyle(
    color: isPositive ? positiveColor : negativeColor,
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );
} 