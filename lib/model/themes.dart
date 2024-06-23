import 'package:flutter/material.dart';

final ThemeData classicLightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: Colors.white,
    onPrimary: Colors.black,
    secondary: Color.fromARGB(255, 254, 244, 244),
    onSecondary: Colors.black,
    tertiary: Color.fromRGBO(255, 158, 158, 158),
    onTertiary: Colors.white,
    error: Colors.red,
    onError: Colors.white,
    surface: Colors.white,
    onSurface: Colors.black,
    background: Colors.green,
    onBackground: Colors.green,
  ),
);

final ThemeData classicDarkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    primary: Colors.black,
    onPrimary: Colors.white,
    secondary: Color.fromARGB(255, 42, 42, 42),
    onSecondary: Colors.white,
    tertiary: Color.fromRGBO(244, 40, 53, 1),
    onTertiary: Colors.white,
    error: Colors.red,
    onError: Colors.black,
    surface: Colors.black,
    onSurface: Colors.white,
    background: Colors.green,
    onBackground: Colors.green,
  ),
);

final ThemeData lightForestTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFFF7DCB9),
    onPrimary: Color.fromARGB(255, 160, 129, 97),
    secondary: Color(0xFFB5C18E),
    onSecondary: Colors.black,
    tertiary: Color(0xFFAF8F6F),
    onTertiary: Colors.white,
    error: Colors.red,
    onError: Colors.white,
    surface: Colors.white,
    onSurface: Colors.black,
    background: Colors.green,
    onBackground: Colors.green,
  ),
);

final ThemeData sunnyBeachTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFFCAF4FF),
    onPrimary: Color(0xFF5AB2FF),
    secondary: Color(0xFFA0DEFF),
    onSecondary: Colors.black,
    tertiary: Color(0xFFFFF9D0),
    onTertiary: Colors.white,
    error: Colors.red,
    onError: Colors.white,
    surface: Colors.white,
    onSurface: Colors.black,
    background: Colors.green,
    onBackground: Colors.green,
  ),
);

final ThemeData twillightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF824D74),
    onPrimary: Color(0xFFFDAF7B),
    secondary: Color(0xFF401F71),
    onSecondary: Colors.white,
    tertiary: Color(0xFFBE7B72),
    onTertiary: Colors.white,
    error: Colors.red,
    onError: Colors.black,
    surface: Color(0xFF1E1E1E),
    onSurface: Colors.white,
    background: Colors.green,
    onBackground: Colors.green,
  ),
);
