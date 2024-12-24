import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/theme_provider.dart';
import '../widgets/calc_button.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({Key? key}) : super(key: key);

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String input = "";
  String result = "0";
  List<String> history = [];
  bool isScientificMode = false;

  final List<String> basicButtons = [
    "C", "(", ")", "⌫",
    "7", "8", "9", "/",
    "4", "5", "6", "*",
    "1", "2", "3", "-",
    ".", "0", "+", "=",
  ];

  final List<String> scientificButtons = [
    "sin", "cos", "tan", "^",
    "√", "π", "e", "ln",
    ...["C", "(", ")", "⌫", "7", "8", "9", "/", "4", "5", "6", "*", "1", "2", "3", "-", ".", "0", "+", "="],
  ];

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      history = prefs.getStringList('history') ?? [];
    });
  }

  Future<void> saveHistory(String entry) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      history.add(entry);
    });
    await prefs.setStringList('history', history);
  }

  void onButtonPressed(String value) {
    setState(() {
      if (value == "C") {
        input = "";
        result = "0";
      } else if (value == "⌫") {
        if (input.isNotEmpty) {
          input = input.substring(0, input.length - 1);
        }
      } else if (value == "=") {
        try {
          result = evaluateExpression(input); // Final result
          saveHistory("$input = $result");
          input = ""; // Clear input after displaying result
        } catch (e) {
          result = "Error";
        }
      } else {
        if (result != "0" && input.isEmpty) {
          // Start new calculation after result
          result = "0";
        }
        input += value;
        if (_isValidExpression(input)) {
          try {
            result = evaluateExpression(input); // Live updates
          } catch (e) {
            result = "...";
          }
        } else {
          result = "...";
        }
      }
    });
  }



  String evaluateExpression(String expression) {
    try {
      Parser parser = Parser();

      // Automatically add parentheses for scientific functions without them (e.g. sin20 to sin(20))
      expression = expression
          .replaceAllMapped(RegExp(r'(sin|cos|tan|log|sqrt|ln|exp|abs)(\d+\.?\d*)'), (match) {
        String func = match.group(1)!;
        String number = match.group(2)!;
        return "$func($number)"; // Add parentheses around numbers for functions like sin, cos, etc.
      })
          .replaceAllMapped(RegExp(r'sin\(([^)]+)\)'), (match) {
        String angle = match.group(1)!;
        return "sin(${_toRadians(angle)})"; // Convert degrees to radians for sin
      })
          .replaceAllMapped(RegExp(r'cos\(([^)]+)\)'), (match) {
        String angle = match.group(1)!;
        return "cos(${_toRadians(angle)})"; // Convert degrees to radians for cos
      })
          .replaceAllMapped(RegExp(r'tan\(([^)]+)\)'), (match) {
        String angle = match.group(1)!;
        return "tan(${_toRadians(angle)})"; // Convert degrees to radians for tan
      })
          .replaceAll("√", "sqrt") // Replace the square root function
          .replaceAll("π", "3.141592653589793") // Pi constant
          .replaceAll("e", "2.718281828459045") // Euler's number
          .replaceAll("^", "**") // Exponentiation
          .replaceAll("ln", "log"); // Natural logarithm

      Expression exp = parser.parse(expression);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);
      return eval.toString();
    } catch (e) {
      print("Error evaluating expression: $e");
      return "Error";
    }
  }

// Helper function to convert degrees to radians
  double _toRadians(String degree) {
    double value = double.tryParse(degree) ?? 0;
    return value * (3.141592653589793 / 180); // Convert to radians
  }




  bool _isValidExpression(String expression) {
    if (expression.isEmpty) return false;
    final lastChar = expression[expression.length - 1];
    return RegExp(r'[0-9)]').hasMatch(lastChar);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final buttons = isScientificMode ? scientificButtons : basicButtons;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Calculator"),
        actions: [
          IconButton(
            icon: Icon(isScientificMode ? Icons.functions : Icons.calculate),
            onPressed: () {
              setState(() {
                isScientificMode = !isScientificMode;
              });
            },
            tooltip: "Switch Mode",
          ),
          IconButton(
            icon: Icon(themeProvider.isDarkMode ? Icons.sunny : Icons.nights_stay),
            onPressed: themeProvider.toggleTheme,
            tooltip: "Toggle Theme",
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(history[index]),
                    );
                  },
                ),
              );
            },
            tooltip: "View History",
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.centerRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      input,
                      key: ValueKey<String>(input),
                      style: const TextStyle(fontSize: 32),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const SizedBox(height: 10),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      result,
                      key: ValueKey<String>(result),
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1.2,
            ),
            itemCount: buttons.length,
            itemBuilder: (context, index) {
              return CalcButton(
                label: buttons[index],
                onPressed: () => onButtonPressed(buttons[index]),
              );
            },
          ),
        ],
      ),
    );
  }
}
