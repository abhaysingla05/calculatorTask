import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme_provider.dart';
import 'calculator_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(seconds: 2),
              curve: Curves.easeInOut,
              child: Column(
                children: [
                  const Icon(Icons.calculate_outlined, size: 100, color: Colors.blue),
                  const SizedBox(height: 20),
                  const Text(
                    "Welcome to the Gen Z Calculator",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "\"Mathematics is the music of reason.\"",
                    style: TextStyle(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CalculatorScreen()),
                );
              },
              icon: const Icon(Icons.calculate),
              label: const Text("Start Calculating"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            IconButton(
              icon: Icon(themeProvider.isDarkMode ? Icons.sunny : Icons.nights_stay),
              onPressed: themeProvider.toggleTheme,
              tooltip: "Toggle Theme",
            ),
          ],
        ),
      ),
    );
  }
}
