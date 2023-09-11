import 'package:flutter/material.dart';

Color primaryColor = const Color(0xFF2A7BFF);
Color secondaryColor = const Color(0xFFFF9000);

MaterialColor customSwatch = MaterialColor(
  primaryColor.value,
  <int, Color>{
    50: primaryColor,
    100: primaryColor,
    200: primaryColor,
    300: primaryColor,
    400: primaryColor,
    500: primaryColor,
    600: primaryColor,
    700: primaryColor,
    800: primaryColor,
    900: primaryColor,
  },
);

final ThemeData appTheme = ThemeData(
  primarySwatch: customSwatch,
  primaryColor: primaryColor,
  hintColor: secondaryColor,
  buttonTheme: ButtonThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    buttonColor: primaryColor,
    textTheme: ButtonTextTheme.primary,
    minWidth: 0,
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
  ),
  textTheme: TextTheme(
    displayLarge: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: primaryColor,
    ),
    displayMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: secondaryColor,
    ),
  ),
  appBarTheme: AppBarTheme(
    color: primaryColor,
    elevation: 4,
    titleTextStyle: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    iconTheme: const IconThemeData(
      color: Colors.white,
    ),
  ),
);
