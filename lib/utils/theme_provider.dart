import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool isDarkMode = true; // Default to dark mode

  ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    textTheme: const TextTheme(
      bodyText2: TextStyle(fontSize: 18),
    ),
  );

  ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blueGrey,
    textTheme: const TextTheme(
      bodyText2: TextStyle(fontSize: 18, color: Colors.white),
    ),
  );

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }
}
